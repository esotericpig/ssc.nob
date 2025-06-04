# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of SSC.Nob.
# Copyright (c) 2020-2021 Bradley Whited
#
# SPDX-License-Identifier: GPL-3.0-or-later
#++

TESTING = ($PROGRAM_NAME == __FILE__)

if TESTING
  require 'rubygems'
  require 'bundler/setup'
end

require 'attr_bool/core_ext'
require 'ssc.bot'
require 'ssc.bot/user/jrobot_message_sender'
require 'time'

require 'ssc.nob/config'
require 'ssc.nob/error'
require 'ssc.nob/userface'
require 'ssc.nob/util'
require 'ssc.nob/version'

###
# @author Bradley Whited
# @since  0.1.0
###
module SSCNob
  def self.run
    nober = Nober.new

    nober.run
  end

  def self.uface
    return Userface.instance
  end

  ###
  # @author Bradley Whited
  # @since  0.1.1
  ###
  class Nober
    include Uface

    attr_reader :chat_log
    attr_reader :config
    attr_reader :msg_sender
    attr_reader :nob
    attr_reader :nob_time
    attr_reader :nobing
    attr_reader :players
    attr_accessor? :testing
    attr_reader :thread

    def initialize
      super

      @beer = false
      @chat_log = nil
      @config = Config.new
      @donation = nil
      @msg_sender = SSCBot::User::JRobotMessageSender.new
      @nob = nil
      @nob_time = Time.now
      @nobing = false
      @players = {}
      @testing = false
      @thread = nil

      @lotto_bot = false
      @moka_bot = false
      @poker_bot = false
      @poker_thread = nil
    end

    def run
      begin
        puts
        @config.user_init!
        puts
      rescue UserError => e
        puts
        puts uface.error(e)

        return
      end

      @msg_sender.msg_key = @config.build_msg_key
      # @msg_sender.warn_user = true

      @chat_log = SSCBot::ChatLog.new(File.join(@config.build_ssc_log_dir,'nob.log'))

      @chat_log.add_observer(self,:handle_kill_msg,type: :kill)
      @chat_log.add_observer(self,:handle_msg)
      @chat_log.add_observer(self,:handle_chat_msg,type: :chat)
      @chat_log.add_observer(self,:handle_pub_msg,type: :pub)
      @chat_log.add_observer(self,:handle_q_namelen_msg,type: %s(?namelen))
      @chat_log.add_observer(self,:moka_bot)
      @chat_log.add_observer(self,:lotto_bot)
      @chat_log.add_observer(self,:poker_bot)

      puts <<~HELP
        #{uface.title('COMMANDS')}
        #{uface.cmd('run')}           runs Nob
        #{uface.cmd('stop')}          stops Nob
        #{uface.cmd('exit, quit')}    goodbye, user
      HELP
      puts

      loop do
        cmd = uface.ask(uface.gt)
        cmd = Util.strip(cmd.to_s).downcase

        case cmd
        when 'exit','quit'
          @chat_log.stop

          puts
          uface.types("You don't #{uface.love('love')} me? #{uface.love('<3')}")
          puts

          return
        when 'run'
          if @chat_log.alive?
            puts
            puts uface.error('stop the current Nob first, user.')
            puts
          else
            @chat_log.run
          end
        when 'stop'
          @chat_log.stop
        else
          puts
          puts uface.error("that's an invalid command, user.")
          puts
        end
      end
    end

    def handle_kill_msg(_chat_log,msg)
      killed_username = msg.killed
      killer_username = msg.killer

      killed = @players[killed_username]
      killer = @players[killer_username]

      if @nobing && !killed.nil?
        if killed.username == @nob
          killed.time += (Time.now - @nob_time)
          @nob_time = Time.now

          if killer.nil?
            killer = Player.new(killer_username)
            @players[killer.username] = killer
          end

          killer.nobs += 1
          @nob = killer.username

          send_nob_msg("{#{killer.username}} is now the Nob!")
        end

        # Only increment for people playing.
        if !killer.nil?
          killed.deaths += 1
          killer.kills += 1
        end
      elsif @moka_bot
        if killed.nil?
          killed = Player.new(killed_username)
          @players[killed.username] = killed
        end

        if killer.nil?
          killer = Player.new(killer_username)
          @players[killer.username] = killer
        end

        killed.deaths += 1
        killer.kills += 1
      end
    end

    def handle_msg(_chat_log,msg)
      if @beer && msg.line.start_with?('  TEAM: ')
        team = msg.line[8..-1]

        team.split(/\(\d+\),?/).each do |mem|
          mem = Util.strip(mem)
          @players[mem] = true
        end
      end
    end

    def moka_bot(_chat_log,msg)
      if msg.type_chat?
        # channel = msg.channel
        message = msg.message
        username = msg.name

        if username == @config.username
          cmd = message.downcase

          case cmd
          when '!moka.start'
            return if @moka_bot

            @players = {}
            # @testing = true

            mins = @testing ? 1 : 5

            if !@thread.nil?
              @thread.kill if @thread.alive?
              @thread = nil
            end

            send_msg("Moka} Moka (MOst KillA) bot loaded for #{mins} minutes.")
            send_msg('Moka} Top Moka gets a cup of tea!')

            @moka_bot = true

            @thread = Thread.new do
              sleep((mins - 1) * 60)

              tops = @players.values.sort do |p1,p2|
                i = p2.kills <=> p1.kills
                i = p1.deaths <=> p2.deaths if i == 0
                i
              end
              top = tops[0]

              send_msg('Moka} 1 Moka minute remaining!')

              if !top.nil?
                send_msg(
                  "Moka} c\\#{top.username}/ is the current Moka " \
                  "with #{top.kills} kill#{top.kills == 1 ? '' : 's'} " \
                  "and #{top.deaths} death#{top.deaths == 1 ? '' : 's'}!"
                )
              end

              sleep(60) # 1 min

              @moka_bot = false

              tops = @players.values.sort do |p1,p2|
                i = p2.kills <=> p1.kills
                i = p1.deaths <=> p2.deaths if i == 0
                i
              end

              moka_recs = {}
              moka_recs_count = 0

              tops.each do |t|
                mr = moka_recs[t.rec]

                if mr.nil?
                  moka_recs[t.rec] = mr = []
                  moka_recs_count += 1
                end

                mr << t

                if moka_recs_count >= 5
                  break
                end
              end

              send_msg('Moka} Moka bot ended!')
              # send_msg(sprintf('Moka}    | %-24s | Kills:Deaths','Top 5'))
              # send_msg("Moka}    | #{'-' * 24} | #{'-' * 12}")

              # tops.each_with_index() do |player,i|
              #   msg = sprintf("##{i + 1} | %-24s | %-12s",
              #     player.username,player.rec,
              #   )
              #
              #   send_msg("Moka} #{msg}")
              # end

              msg = []

              # tops.each_with_index() do |player,i|
              moka_recs.each_with_index do |(rec,players),i|
                if players.length == 1
                  player = players[0]
                  msg << "##{i + 1} #{player.username}(#{rec})"
                else
                  names = players.map(&:username)
                  msg << "##{i + 1} (#{names.join(', ')})(#{rec})"
                end
              end

              send_msg("Moka} #{msg.join('; ')}")

              # top = tops[0]
              top = moka_recs.values[0]

              if !top.nil?
                send_msg('%10')

                if top.length == 1
                  top = top[0]

                  send_msg("Moka} c\\#{top.username}/ is the Moka! Congrats!")
                  send_msg(":TW-PubSystem:!buy tea:#{top.username}")
                else
                  top.each do |t|
                    send_msg("Moka} c\\#{t.username}/ is a Moka! Congrats!")
                    send_msg(":TW-PubSystem:!buy tea:#{t.username}")
                  end
                end
              end
            end
          when '!moka.stop'
            @moka_bot = false
            @players = {}

            if !@thread.nil?
              @thread.kill if @thread.alive?
              @thread = nil
            end
          end
        end
      end
    end

    def lotto_bot(_chat_log,msg)
      if msg.type_chat?
        # channel = msg.channel
        message = msg.message
        username = msg.name

        if username == @config.username
          cmd = message.downcase

          case cmd
          when '!lotto.start'
            @lotto_bot = true

            send_chat_msg(0,'lotto bot loaded')
          when '!lotto.stop'
            @lotto_bot = false

            send_chat_msg(0,'lotto bot ended')
          end
        end
      end

      # '  [LOTTERY]  PM !guess <#> from 1 - 100. Tickets $2,500' \
      # '  Jackpot $300,000  (Within 1=50%,~5=20%)  -TW-PubSystem'
      if @lotto_bot && msg.line.start_with?('  [LOTTERY]  PM !guess <#> from')
        rand_num = rand(1..100) # 1-100

        send_pub_msg(":TW-PubSystem:!guess #{rand_num}")
      end
    end

    def poker_bot(_chat_log,msg)
      if msg.type_chat?
        # channel = msg.channel
        message = msg.message
        username = msg.name

        if username == @config.username
          cmd = message.downcase

          case cmd
          when '!poker.start'
            return if @poker_bot

            if @poker_thread
              @poker_thread.kill if @poker_thread.alive?
              @poker_thread = nil
            end

            # send_chat_msg(0,'poker bot loaded')
            puts 'Poker bot loaded!'

            @poker_bot = true

            @poker_thread = Thread.new do
              while @poker_bot
                @poker_hand = nil

                send_pub_msg(':TW-PubSystem:!poker')

                sleep(15)

                if @poker_hand.nil?
                  puts 'Killing poker bot!'
                  @poker_bot = false
                  break
                end

                puts @poker_hand
                ph = PokerHand.new(@poker_hand)
                puts ph
                resp = ph.compute_response
                puts resp

                send_pub_msg(":TW-PubSystem:!poker #{resp}")

                sleep(15)
              end
            end
          when '!poker.stop'
            @poker_bot = false

            if @poker_thread
              @poker_thread.join(5)
              @poker_thread.kill if @poker_thread.alive?
              @poker_thread = nil
            end

            # send_chat_msg(0,'poker bot killed')
            puts 'Poker bot killed!'
          end
        end
      end

      # TW-PubSystem> 1)        Jh 7s 7h 3h 3c ...
      if @poker_bot && msg.type_private?
        message = msg.message
        username = msg.name

        if username.casecmp?('TW-PubSystem') && message.start_with?('1)')
          match = /1\)\s+(?<hand>\S+\s+\S+\s+\S+\s+\S+\s+\S+)\s+.*/.match(message)

          if match
            @poker_hand = match[:hand]
          end
        end
      end
    end

    class PokerHand
      attr_accessor :cards
      attr_accessor :value
      attr_accessor :values

      def initialize(hand)
        super()

        @cards = []
        @value = 0
        @values = []

        hand.split(/[[:space:]]+/).each do |card|
          next if card.length != 2

          value = card[0]
          suit = card[1].to_sym

          @cards << Card.new(value,suit)
        end
      end

      def compute_response
        is_flush = true
        flushes = {}
        ofakinds = Array.new(13) { 0 }
        prev_suit = nil
        values = []
        near_flush = false
        near_flush_suit = nil

        @cards.each do |card|
          ofakinds[card.value - 2] += 1
          values << card.value

          f = flushes.fetch(card.suit,0)
          f += 1
          flushes[card.suit] = f

          if flushes[card.suit] >= 3
            near_flush = true
            near_flush_suit = card.suit
          end

          if !prev_suit.nil? && card.suit != prev_suit
            is_flush = false
          end

          prev_suit = card.suit
        end

        is_2ofakind = false
        is_2pair = false
        is_3ofakind = false
        is_4ofakind = false

        ofakinds.each do |oak|
          case oak
          when 2
            if is_2ofakind
              is_2pair = true
            else
              is_2ofakind = true
            end
          when 3 then is_3ofakind = true
          when 4 then is_4ofakind = true
          end
        end

        values.sort!

        is_bicycle = (values[0] == 2 && values[-1] == 14) # 14=Ace
        is_straight = true
        straight_value = values[0]

        len = values.length - 1
        len -= 1 if is_bicycle

        bs_values = []
        bs_count = 0

        1.upto(len) do |i|
          straight_value += 1
          value = values[i]

          if value != straight_value
            bs_values << value
            bs_count += 1
            is_straight = false
          end
        end

        if is_straight && is_bicycle
          # Change Ace value to 1 for a bicycle (wheel) straight.
          values[-1] = 1

          values.sort!
        end

        if is_straight || is_flush || (is_3ofakind && is_2ofakind)
          return 'ooooo'
        end

        if is_4ofakind || is_3ofakind || is_2pair || is_2ofakind
          resp = ''.dup

          @cards.each do |card|
            oak = ofakinds[card.value - 2]
            resp << ((oak >= 2) ? 'o' : 'x')
          end

          return resp
        end

        # Near straight?
        if bs_count == 1 || bs_count == 2
          resp = ''.dup

          @cards.each do |card|
            resp << (bs_values.include?(card.value) ? 'x' : 'o')
          end

          return resp
        end

        # Near flush?
        if near_flush
          resp = ''.dup

          @cards.each do |card|
            resp << ((card.suit != near_flush_suit) ? 'x' : 'o')
          end

          return resp
        end

        # Just do high cards
        high_cards = [values[-1]]
        high_cards << values[-2] if rand(2) == 0

        resp = ''.dup

        @cards.each do |card|
          resp << (high_cards.include?(card.value) ? 'o' : 'x')
        end

        return resp
      end

      def valid?
        return @cards.length == 5
      end

      def to_s
        return @cards.join(' ')
      end
    end

    class Card
      attr_accessor :norm
      attr_accessor :rank
      attr_accessor :suit
      attr_accessor :value

      def initialize(rank,suit)
        super()

        @rank = rank
        @suit = suit

        @value =
          case rank
          when 'T' then 10
          when 'J' then 11
          when 'Q' then 12
          when 'K' then 13
          when 'A' then 14
          else
            rank.to_i
          end

        @norm = @value

        case suit
        when :c then @norm += 100
        when :d then @norm += 200
        when :h then @norm += 300
        when :s then @norm += 400
        else
          raise ArgumentError,"invalid suit{#{suit}}"
        end
      end

      def <=>(other)
        c = (@suit <=> other.suit)
        c = @value <=> other.value if c == 0

        return c
      end

      def inspect
        return "#{@rank}(#{@value})#{@suit}"
      end

      def to_s
        return "#{@rank}#{@suit}"
      end
    end

    def handle_chat_msg(_chat_log,msg)
      message = msg.message
      username = msg.name

      if username == @config.username
        cmd = message.downcase

        if cmd.include?('!beer.start')
          @beer = true
        elsif cmd.include?('!beer.list')
          send_chat_msg(4,"players: #{@players.length}")
          send_chat_msg(4,@players.keys.join(', '))
        elsif cmd.include?('!beer.me')
          if @beer
            @beer = false

            @players.each_key do |name|
              next if name == @config.username

              send_pub_msg(":TW-PubSystem:!buy beer:#{name}")
              sleep(6)
            end

            @players = {}
          end
        elsif cmd.include?('!beer.stop')
          @beer = false
          @players = {}
        elsif cmd.start_with?('!nob.start')
          return if @nobing # Already nobing

          opts_msg = Util.strip(message)
          opts_msg = Util.strip(opts_msg[10..-1])
          opts_msg = opts_msg.split(',')

          opts = {}

          opts_msg.each do |om|
            om = om.split('=',2)
            opts[om[0]] = om[1]
          end

          @donation = opts['donate']
          @donation = nil if Util.blank?(@donation)
          mins = opts.key?('mins') ? opts['mins'].to_i : 5
          @nob = opts.key?('nob') ? opts['nob'] : @config.username
          @testing = true if opts.key?('test')

          @players = {
            @nob => Player.new(@nob,nobs: 1),
          }

          if !@thread.nil?
            @thread.kill if @thread.alive?

            @thread = nil
          end

          send_nob_msg("Nob bot loaded (Noble One) for #{mins} min.")
          send_nob_msg("Kill {#{@nob}} to become the Nob!")

          if !@donation.nil?
            send_nob_msg("Top Nob gets #{@donation} pub bux!")
          end

          @nobing = true
          @nob_time = Time.now

          @thread = Thread.new do
            sleep(mins * 60)

            @nobing = false

            nobler = @players[@nob]
            nobler.time += (Time.now - @nob_time)

            tops = @players.values.sort do |p1,p2|
              p2.time <=> p1.time
            end
            tops = tops[0..4]

            send_nob_msg('Nob bot ended!')
            send_nob_msg(format('   | %-24s | # of Nobs | Kills:Deaths | Time','Nobler'))
            send_nob_msg("   | #{'-' * 24} | #{'-' * 9} | #{'-' * 12} | #{'-' * 8}")

            tops.each_with_index do |top,i|
              msg = format("##{i + 1} | %-24s | %-9s | %-12s | %.2f secs",
                           top.username,top.nobs,top.rec,top.time.round(2))

              send_nob_msg(msg)
            end

            top = tops[0]

            send_nob_msg("{#{top.username}} is the top Nob! Congrats!")

            if !@donation.nil?
              send_pub_msg(":TW-PubSystem:!donate #{top.username}:#{@donation}")
            end
          end
        elsif cmd.include?('!nob.stop')
          @nobing = false
          @players = {}

          if !@thread.nil?
            @thread.kill if @thread.alive?

            @thread = nil
          end
        end
      end
    end

    def handle_pub_msg(chat_log,msg)
    end

    def handle_q_namelen_msg(_chat_log,msg)
      puts
      puts "Using namelen{#{msg.namelen}}."
      print uface.gt
    end

    def send_chat_msg(channel,msg)
      @msg_sender.send_chat_to(channel,msg)
    end

    def send_nob_msg(msg)
      if @testing
        send_chat_msg(0,msg)
      else
        send_pub_msg("nob} #{msg}")
      end
    end

    def send_pub_msg(msg)
      @msg_sender.send_safe(msg)
    end

    def send_msg(msg)
      if @testing
        send_chat_msg(0,msg)
      else
        send_pub_msg(msg)
      end
    end
  end

  ###
  # @author Bradley Whited
  # @since  0.1.1
  ###
  class Player
    attr_accessor :deaths
    attr_accessor :kills
    attr_accessor :nobs
    attr_accessor :time
    attr_accessor :username

    def initialize(username,deaths: 0,kills: 0,nobs: 0,time: 0)
      @deaths = deaths
      @kills = kills
      @nobs = nobs
      @time = time
      @username = username
    end

    def rec
      return "#{@kills}:#{@deaths}"
    end
  end
end

if TESTING
  SSCNob.run
end
