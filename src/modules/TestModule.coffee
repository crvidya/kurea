module.exports = (Module) ->
	Q = require('q')
	fs = require('fs')
	
	class TestModule extends Module
		shortName: "Test"
		helpText:
			default: "Some basstest stuff."
			secretilluminaticommand: "no longer a secret"
	
		constructor: (moduleManager) ->
			super(moduleManager)
	
			@addRoute "test", (origin, route) =>
				[bot, channel, user] = [origin.bot, origin.channel, origin.user]
	
				# if not @hasPermission(bot, user, "test.use")
				# 	bot.say(channel, "You do not have the necessary permission! This requires test.use!")
				# 	return
	
				bot.say(channel, "Hi, my name is #{bot.getName()} but you can call me #{bot.getNick()}!")
				bot.say(channel, "I'm currently in the server #{bot.getServer()} in the channels #{bot.getChannels().join(", ")}!")
				bot.say(channel, "My user manager is #{bot.userManager.shortName}!")
				console.log route
	
				bot.userManager.getUsername origin, (err, username) =>
					if err?
						bot.say(channel, "Welp error: #{err}")
						return
	
					bot.say(channel, "Your username is #{username}!")
	
			permtest = (origin, route) =>
				perm = route.params.perm ? "access.test"
	
				@hasPermission origin, perm, (err, matched) =>
					if err?
						console.error err.stack
						@reply origin, "There was an error! #{err.message}"
						return

					if matched
						@reply origin, "You have permission #{perm}!"
					else
						@reply origin, "BEEP BEEP you lack permission #{perm}"
	
			@addRoute "permtest", permtest
			@addRoute "permtest :perm", permtest

			@addRoute "permaddtest", "access.permaddtest", (origin, route) =>
				@reply origin, "Hello! Thank you for using KellyIRC Programmers Permission System."

			@addRoute "test-set :key :value", (origin, route) =>
				[key, value] = [route.params.key, route.params.value]

				@settings.set key, value
				@reply origin, "Set key #{key} to value '#{value}'"

			@addRoute "test-get :key", (origin, route) =>
				[key, value] = [route.params.key, @settings.get route.params.key]
				
				@reply origin, "Key #{key} has the value '#{value}'"
	
			@addRoute "info :chan", (origin, route) =>
				[bot, channel, user, chan] = [origin.bot, origin.channel, origin.user, route.params.chan]
				bot.say channel, "These users are in #{chan}: #{bot.getUsersWithPrefix(chan).join(", ")}"
				bot.say channel, "The topic is: #{bot.getTopic(chan)}"
	
			@addRoute "qtest", (origin, route) =>
				Q.fcall ->
					Q.nfcall fs.readFile, "package.json"
	
				.then (x) ->
					console.log "Durr", "ALRIGHT #{x}"
	
				.fail (err) ->
					console.log "Error:", err
	
			@addRoute "qtest :other", (origin, route) =>
				Q.fcall =>
					other = route.params.other
					perm = "access.test"
	
					Q.all [
						Q.nfcall @hasPermission, origin, perm
						Q.nfcall @hasPermission, {bot: origin.bot, channel: origin.channel, user: other}, perm
					]
	
				.then (matches) ->
					console.log "The matches are", matches
	
				.fail (err) ->
					console.log "THIS IS AN ERROR:", err
	
	
	TestModule