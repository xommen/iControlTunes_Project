--
--  MacOS_X_iTunes_RemoteAppDelegate.applescript
--  MacOS X iTunes Remote
--
--  Created by Wim van Ommen on 4/28/11.
--  Copyright 2011 TopIT. All rights reserved.
--
script MacOS_X_iTunes_RemoteAppDelegate
	property parent : class "NSObject"
	property NSString : class "NSString"
	property theVolumeSlider : missing value
	property theVolumeSlider2 : missing value
	property songTitle : missing value
	property songArtist : missing value
	property songAlbum : missing value
	property songTitle2 : missing value
	property songArtist2 : missing value
	property songAlbum2 : missing value
	property songArtwork : missing value
	property findArtist : missing value
	property myItunesHost : missing value
	property mySessionID : missing value
	property myErrorMessage : missing value
	property LaunchWindows : missing value
	property SmallerWindows : missing value
	property LaunchState : missing value
	on SmallerWindowShow_(aNotification)
		SmallerWindows's makeKeyAndOrderFront_(me)
		LaunchWindows's orderOut_(me)
		set LaunchState to "SmallerWindow"
	end SmallerWindowShow_
	
	on LaunchWindowShow_(aNotification)
		LaunchWindows's makeKeyAndOrderFront_(me)
		SmallerWindows's orderOut_(me)
		set LaunchState to "NormalWindow"
	end LaunchWindowShow_
	
	on SearchReplace(sourceStr, searchString, replaceString)
		-- replace <searchString> with <replaceString> in <sourceStr> 
		set searchStr to (searchString as text)
		set replaceStr to (replaceString as text)
		set sourceStr to (sourceStr as text)
		set saveDelims to AppleScript's text item delimiters
		set AppleScript's text item delimiters to (searchString)
		set theList to (every text item of sourceStr)
		set AppleScript's text item delimiters to (replaceString)
		set theString to theList as string
		set AppleScript's text item delimiters to saveDelims
		return theString
	end SearchReplace
	
	on trim(someText)
		set AppleScript's text item delimiters to {""}
		repeat until someText does not start with " "
			set someText to text 2 thru -1 of someText
		end repeat
		
		repeat until someText does not end with " "
			set someText to text 1 thru -2 of someText
		end repeat
		
		return someText
	end trim
	on help_(sender)
		tell application "Safari"
			activate
			make new document with properties {URL:"http://www.vanommen.net/itunesremote.php"}
		end tell
	end help_
	
	on playSpecificArtist_(sender)
		set AppleScript's text item delimiters to {""}
		tell current application
			set theArtist to findArtist's objectValue() as text
			set myString to NSString's stringWithString_(theArtist)
			set theartistlist12 to myString's stringByAddingPercentEscapesUsingEncoding_(current application's NSUTF8StringEncoding) as string
			set theArtist to my SearchReplace(theartistlist12, "'", "%5C'")
			do shell script "curl -vvv -m 2 -H \"Viewer-Only-Client: 1\"  \"http://" & myItunesHost & ":3689/ctrl-int/1/cue?command=play&query=(('daap.songartist:" & theArtist & "','daap.songalbumartist:" & theArtist & "')+('com.apple.itunes.mediakind:1','com.apple.itunes.mediakind:32'))&dacp.shufflestate=1&sort=name&clear-first=1&session-id=" & mySessionID & "\"  | python ~/Library/Preferences/iTunesRemote/decode.py "
		end tell
	end playSpecificArtist_
	
	on SelectArtist_(sender)
		set AppleScript's text item delimiters to {""}
		set thevalue to do shell script "curl -vvv -H \"Viewer-Only-Client: 1\"  \"http://" & myItunesHost & ":3689/ctrl-int/1/databases?session-id=" & mySessionID & "\"  | python ~/Library/Preferences/iTunesRemote/decode.py | grep miid"
		set AppleScript's text item delimiters to {"=="}
		set thevalues to get text items of thevalue
		set AppleScript's text item delimiters to {""}
		set thecount to count thevalues
		set thedbid to get item thecount of thevalues
		set myid to thedbid + 0
		try
			set theArtistList to do shell script "curl -vvv -H \"Viewer-Only-Client: 1\"  \"http://" & myItunesHost & ":3689/databases/" & myid & "/browse/artists?session-id=" & mySessionID & "\""
		end try
		set theartistlist2 to SearchReplace(theArtistList, return, "")
		set theartistlist2 to SearchReplace(theartistlist2, "", "")
		set theartistlist3 to SearchReplace(theartistlist2, tab, "")
		set AppleScript's text item delimiters to {"mlit"}
		set theartistlist4 to text items of theartistlist3
		set thecount to count theartistlist4
		set theartistlist4 to items 2 thru thecount of theartistlist4
		set AppleScript's text item delimiters to {""}
		set theartistlist5 to choose from list theartistlist4
		set theartistlist6 to SearchReplace(theartistlist5, return, "")
		set theartistlist7 to SearchReplace(theartistlist6, "", "")
		set theartistlist8 to SearchReplace(theartistlist7, tab, "")
		set theartistlist9 to theartistlist8 as Unicode text
		set theartistlist10 to theartistlist9 as text
		set theartistlist11 to trim(theartistlist10)
		set myString to NSString's stringWithString_(theartistlist11)
		set theartistlist12 to myString's stringByAddingPercentEscapesUsingEncoding_(current application's NSUTF8StringEncoding)
		set theartistlist12 to SearchReplace(theartistlist12, "%00", "")
		set theArtist to SearchReplace(theartistlist12, "'", "%5C'")
		do shell script "curl -vvv -m 2 -H \"Viewer-Only-Client: 1\"  \"http://" & myItunesHost & ":3689/ctrl-int/1/cue?command=play&query=(('daap.songartist:" & theArtist & "','daap.songalbumartist:" & theArtist & "')+('com.apple.itunes.mediakind:1','com.apple.itunes.mediakind:32'))&dacp.shufflestate=1&sort=name&clear-first=1&session-id=" & mySessionID & "\"  | python ~/Library/Preferences/iTunesRemote/decode.py "
	end SelectArtist_
	
	on VolumeSliderChange_(sender)
		set AppleScript's text item delimiters to {""}
		set AppleScript's text item delimiters to {""}
		set VolumeSliderCurrent to theVolumeSlider's doubleValue()
		tell current application
			set thevalue to do shell script "curl -vvv -m 2 -H \"Viewer-Only-Client: 1'\" \"http://" & myItunesHost & ":3689/ctrl-int/1/setproperty?dmcp.volume=" & VolumeSliderCurrent & ".000000&session-id=" & mySessionID & "\""
		end tell
	end VolumeSliderChange_
	
	on applicationWillFinishLaunching_(aNotification)
		if LaunchState is "SmallerWindow" then
			my SmallerWindowShow_("send")
		end if
		set AppleScript's text item delimiters to {""}
		set destpath2 to path to preferences
		set destpath to destpath2 & "iTunesRemote" & ":" as string
		try
			tell application "Finder"
				alias destpath
			end tell
		on error
			tell application "Finder"
				make new folder at destpath2 with properties {name:"iTunesRemote"}
			end tell
		end try
		set iTunesServerHostFile to destpath & "com.iTunesRemote.ituneshost.txt" as string
		try
			tell application "Finder"
				alias iTunesServerHostFile
				open for access file iTunesServerHostFile
				set theiTunesServer to read file iTunesServerHostFile
				close access file iTunesServerHostFile
				set myItunesHost to theiTunesServer
			end tell
		on error
			tell application "Finder"
				set thedialog to display dialog "please enter iTunes servername" default answer ""
			end tell
			set theiTunesServer to text returned of thedialog
			tell current application
				open for access file iTunesServerHostFile with write permission
				set eof file iTunesServerHostFile to 0
				write theiTunesServer to file iTunesServerHostFile starting at eof
				close access file iTunesServerHostFile
				set myItunesHost to theiTunesServer
			end tell
		end try
		-- try to start iTunes on remote if not yet running only works if helper is started on remote mac
		try
			set theSessionValue to do shell script "curl -vvv -m 3 -H \"Viewer-Only-Client: 1\"  http://" & myItunesHost & ":3689/login?pairing-guid=0x0000000000000001 | python ~/Library/Preferences/iTunesRemote/decode.py | grep mlid"
		on error
			try
				do shell script "curl -vvv -m 2  http://" & myItunesHost & ":9090"
				myErrorMessage's setStringValue_("Please be patient, trying to start iTunes on Remote")
				delay 15
				myErrorMessage's setStringValue_("")
			end try
		end try
		-- create pairremote.py if it's not there yet		
		set PairingFile to destpath & "pairremote.py" as string
		try
			tell application "Finder"
				alias PairingFile
			end tell
		on error
			tell current application
				open for access file PairingFile with write permission
				set eof file PairingFile to 0
				write "from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
import struct, os,time
class PairingHandler(BaseHTTPRequestHandler):
	def do_GET(self):
		values = {
			'cmpg': '\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x01',
			'cmnm': 'devicename',
			'cmty': 'ipod',
			}
		encoded = ''
		for key, value in values.iteritems():
			encoded += '%s%s%s' % (key, struct.pack('>i', len(value)), value)
		header = 'cmpa%s' % (struct.pack('>i', len(encoded)))
		encoded = '%s%s' % (header, encoded)
		self.send_response(200)
		self.end_headers()
		self.wfile.write(encoded)
		os.system('echo ' + self.client_address[0] + ' >> ~/Library/Preferences/iTunesRemote/com.iTunesRemote.ituneshostslist.txt')
		os.system('killall mDNS')
		os.system('killall python')
		return
try:
	port = 1024
	server = HTTPServer(('', port), PairingHandler)
	print 'started server on port %s' % (port)
	server.serve_forever()
except KeyboardInterrupt:
	server.socket.close()" to file PairingFile starting at eof
				close access file PairingFile
			end tell
		end try
		-- create decode.py if it's not there yet		
		set DecoderFile to destpath & "decode.py" as string
		try
			tell application "Finder"
				alias DecoderFile
			end tell
		on error
			tell current application
				open for access file DecoderFile with write permission
				set eof file DecoderFile to 0
				write "# simple message decoder for dacp
# released gplv3 by jeffrey sharkey
import sys, struct, re
raw = []
#for c in raw_input(): raw.append(c)
#raw.append('\\x0a')
for c in sys.stdin.read(): raw.append(c)

def format(c):
	if ord(c) >= 128: return \"(byte)0x%02x\"%ord(c)
	else: return \"0x%02x\"%ord(c)
print ','.join([ format(c) for c in raw ])

def read(queue, size):
	pull = ''.join(queue[0:size])
	del queue[0:size]
	return pull
group = ['cmst','mlog','agal','mlcl','mshl','mlit','abro','abar','apso','caci','avdb','cmgt','aply','adbs','cmpa']
rebinary = re.compile('[^\\x20-\\x7e]')
def ashex(s): return ''.join([ \"%02x\" % ord(c) for c in s ])
def asbyte(s): return struct.unpack('>B', s)[0]
def asint(s): return struct.unpack('>I', s)[0]
def aslong(s): return struct.unpack('>Q', s)[0]

def decode(raw, handle, indent):
	while handle >= 8:
		
		# read word data type and length
		ptype = read(raw, 4)
		plen = asint(read(raw, 4))
		handle -= 8 + plen
		
		# recurse into groups
		if ptype in group:
			print '\\t' * indent, ptype, \" --+\"
			decode(raw, plen, indent + 1)
			continue
		
		# read and parse data
		pdata = read(raw, plen)
		
		nice = '%s' % ashex(pdata)
		if plen == 1: nice = '%s == %s' % (ashex(pdata), asbyte(pdata))
		if plen == 4: nice = '%s == %s' % (ashex(pdata), asint(pdata))
		if plen == 8: nice = '%s == %s' % (ashex(pdata), aslong(pdata))
		
		if rebinary.search(pdata) is None:
			nice = pdata
		
		print '\\t' * indent, ptype.ljust(6), str(plen).ljust(6), nice

decode(raw, len(raw), 0)" to file DecoderFile starting at eof
				close access file DecoderFile
			end tell
		end try
		try
			set theSessionValue to do shell script "curl -vvv -m 2 -H \"Viewer-Only-Client: 1\"  http://" & myItunesHost & ":3689/login?pairing-guid=0x0000000000000001 | python ~/Library/Preferences/iTunesRemote/decode.py | grep mlid"
		end try
		set AppleScript's text item delimiters to {"=="}
		tell application "Finder"
			set theSessionValues to get text items of theSessionValue
		end tell
		set AppleScript's text item delimiters to {""}
		set theValCount to count theSessionValues
		set theSessionID to get item theValCount of theSessionValues
		set theUsedSessionID to trim(theSessionID)
		set mySessionID to theUsedSessionID
		set theiTunesSession to destpath & "com.iTunesRemote.itunessession.txt" as string
		tell application "Finder"
			open for access file theiTunesSession with write permission
			set eof file theiTunesSession to 0
			write theUsedSessionID to file theiTunesSession starting at eof
			close access file theiTunesSession
		end tell
		my performSelector_withObject_afterDelay_("idleWrapper", missing value, 0.01)
	end applicationWillFinishLaunching_
	
	on PreviousButton_(aNotification)
		set AppleScript's text item delimiters to {""}
		tell current application
			do shell script "curl -vvv -m 2 -H \"Viewer-Only-Client: 1'\" \"http://" & myItunesHost & ":3689/ctrl-int/1/previtem?session-id=" & mySessionID & "\" | python ~/Library/Preferences/iTunesRemote/decode.py"
		end tell
		set theSongName to do shell script "curl -vvv -m 2 -H \"Viewer-Only-Client: 1'\" \"http://" & myItunesHost & ":3689/ctrl-int/1/playstatusupdate?revision-number=1&session-id=" & mySessionID & "\" | python ~/Library/iTunesRemote/Preferencedecode.py | grep cann"
		set theArtist to do shell script "curl -vvv -H -m 2 \"Viewer-Only-Client: 1'\" \"http://" & myItunesHost & ":3689/ctrl-int/1/playstatusupdate?revision-number=1&session-id=" & mySessionID & "\" | python ~/Library/iTunesRemote/Preferences/decode.py | grep cana"
		set theAlbum to do shell script "curl -vvv -H -m 2 \"Viewer-Only-Client: 1'\" \"http://" & myItunesHost & ":3689/ctrl-int/1/playstatusupdate?revision-number=1&session-id=" & mySessionID & "\" | python ~/Library/iTunesRemote/Preferences/decode.py | grep canl"
		set AppleScript's text item delimiters to "     "
		set theSongNameList to text items of theSongName
		set theSongNameCount to count theSongNameList
		set thisSong to item theSongNameCount of theSongNameList
		set theArtistList to text items of theArtist
		set theArtistCount to count theArtistList
		set thisArtist to item theArtistCount of theArtistList
		set theAlbumList to text items of theAlbum
		set theAlbumCount to count theAlbumList
		set thisAlbum to item theAlbumCount of theAlbumList
		tell current application
			songTitle's setStringValue_(thisSong)
			songArtist's setStringValue_(thisArtist)
			songAlbum's setStringValue_(thisAlbum)
			songTitle2's setStringValue_(thisSong)
			songArtist2's setStringValue_(thisArtist)
			songAlbum2's setStringValue_(thisAlbum)
		end tell
		set AppleScript's text item delimiters to {""}
	end PreviousButton_
	
	on PlayButton_(aNotification)
		set AppleScript's text item delimiters to {""}
		tell current application
			do shell script "curl -vvv -m 2 -H \"Viewer-Only-Client: 1\" http://" & myItunesHost & ":3689/ctrl-int/1/playpause?session-id=" & mySessionID & " | python ~/Library/Preferences/iTunesRemote/decode.py"
		end tell
	end PlayButton_
	
	on NextButton_(aNotification)
		set AppleScript's text item delimiters to {""}
		tell current application
			do shell script "curl -vvv -m 2 -H \"Viewer-Only-Client: 1'\" \"http://" & myItunesHost & ":3689/ctrl-int/1/nextitem?session-id=" & mySessionID & "\" | python ~/Library/Preferences/iTunesRemote/decode.py"
		end tell
	end NextButton_
	
	on VolumeDown_(aNotification)
		set AppleScript's text item delimiters to {""}
		tell current application
			set thevalue to do shell script "curl -vvv -m 2 -H \"Viewer-Only-Client: 1'\" \"http://" & myItunesHost & ":3689/ctrl-int/1/getproperty?properties=dmcp.volume&session-id=" & mySessionID & "\" | python~/Library/Preferences/iTunesRemote/decode.py | grep cmvo"
			set AppleScript's text item delimiters to {"=="}
			set thevalues to get text items of thevalue
			set thecount to count thevalues
			set thevolume to get item thecount of thevalues
			set currentvolume to thevolume - 10
			set thevalue to do shell script "curl -vvv -H -m 2 \"Viewer-Only-Client: 1'\" \"http://" & myItunesHost & ":3689/ctrl-int/1/setproperty?dmcp.volume=" & currentvolume & ".000000&session-id=" & mySessionID & "\""
		end tell
		tell current application
			theVolumeSlider's |setDoubleValue_|(currentvolume)
			theVolumeSlider's updateCell
			theVolumeSlider's updateCellInside
		end tell
		set AppleScript's text item delimiters to {""}
	end VolumeDown_
	
	on VolumeUp_(aNotification)
		set AppleScript's text item delimiters to {""}
		tell current application
			set thevalue to do shell script "curl -vvv -H -m 2 \"Viewer-Only-Client: 1'\" \"http://" & myItunesHost & ":3689/ctrl-int/1/getproperty?properties=dmcp.volume&session-id=" & mySessionID & "\" | python ~/Library/Preferences/iTunesRemote/decode.py | grep cmvo"
			set AppleScript's text item delimiters to {"=="}
			set thevalues to get text items of thevalue
			set thecount to count thevalues
			set thevolume to get item thecount of thevalues
			set currentvolume to thevolume + 10
			set thevalue to do shell script "curl -vvv -H -m 2 \"Viewer-Only-Client: 1'\" \"http://" & myItunesHost & ":3689/ctrl-int/1/setproperty?dmcp.volume=" & currentvolume & ".000000&session-id=" & mySessionID & "\""
			tell current application
				theVolumeSlider's |setDoubleValue_|(currentvolume)
				theVolumeSlider's updateCell
				theVolumeSlider's updateCellInside
			end tell
		end tell
		set AppleScript's text item delimiters to {""}
	end VolumeUp_
	
	on RegisterButton_(aNotification)
		set AppleScript's text item delimiters to {""}
		try
			do shell script "killall mDNS"
		end try
		try
			do shell script "killall python"
		end try
		delay 3
		do shell script "mDNS -R \"0000000000000000000000000000000000000001\" _touch-remote._tcp . 1024 DvNm='MacOS Remote' Pair=0000000000000001 > /dev/null 2>&1 &"
		do shell script "python ~/Library/Preferences/iTunesRemote/pairremote.py > /dev/null 2>&1 &"
	end RegisterButton_
	
	on unRegisterButton_(aNotification)
		set AppleScript's text item delimiters to {""}
		try
			do shell script "killall mDNS"
		end try
		try
			do shell script "killall python"
		end try
	end unRegisterButton_
	
	on ChooseOtherServer_(aNotification)
		set AppleScript's text item delimiters to {""}
		set destpath2 to path to preferences
		set destpath to destpath2 & "iTunesRemote" & ":" as string
		set the_file to destpath & "com.iTunesRemote.ituneshost.txt" as string
		tell current application
			set theservers to do shell script "more ~/Library/Preferences/iTunesRemote/com.iTunesRemote.ituneshostslist.txt"
			set AppleScript's text item delimiters to {return}
			set theservers2 to text items of theservers
			set AppleScript's text item delimiters to {""}
			set theserver to choose from list theservers2
			set theserver to theserver as string
			tell application "Finder"
				try
					close access file the_file
				end try
				open for access file the_file with write permission
				set eof file the_file to 0
				write theserver to file the_file starting at eof
				set myItunesHost to theserver
				close access file the_file
			end tell
		end tell
		applicationWillFinishLaunching_(aNotification)
	end ChooseOtherServer_
	
	on applicationShouldTerminate_(sender)
		set AppleScript's text item delimiters to {""}
		-- Insert code here to do any housekeeping before your application quits 
		return current application's NSTerminateNow
	end applicationShouldTerminate_
	
	on refresh_(aNotification)
		set AppleScript's text item delimiters to {""}
		tell current application
			try
				set theSessionValue to do shell script "curl -vvv -m 3 -H \"Viewer-Only-Client: 1\"  http://" & myItunesHost & ":3689/login?pairing-guid=0x0000000000000001 | python ~/Library/Preferences/iTunesRemote/decode.py | grep mlid"
			on error
				my applicationWillFinishLaunching_(aNotification)
			end try
			set destpath2 to path to preferences
			if (theiTunesSession is "") then
				set AppleScript's text item delimiters to {"=="}
				try
					set iTunesVolumeValue to do shell script "curl -vvv -m 3 -H \"Viewer-Only-Client: 1'\" \"http://" & myItunesHost & ":3689/ctrl-int/1/getproperty?properties=dmcp.volume&session-id=" & mySessionID & "\" | python ~/Library/Preferences/iTunesRemote/decode.py | grep cmvo"
				on error
					try
						set theSessionValue to do shell script "curl -vvv -m 3 -H \"Viewer-Only-Client: 1\"  http://" & myItunesHost & ":3689/login?pairing-guid=0x0000000000000001 | python ~/Library/Preferences/iTunesRemote/decode.py | grep mlid"
					end try
					set AppleScript's text item delimiters to {"=="}
					tell application "Finder"
						set theSessionValues to get text items of theSessionValue
					end tell
					set theValCount to count theSessionValues
					set theSessionID to get item theValCount of theSessionValues
					set theUsedSessionID to trim(theSessionID)
					set AppleScript's text item delimiters to {""}
					set theiTunesSession to destpath & "com.iTunesRemote.itunessession.txt" as string
					tell application "Finder"
						try
							close access file theiTunesSession
						end try
						delay 2
						open for access file theiTunesSession with write permission
						set eof file theiTunesSession to 0
						write theUsedSessionID to file theiTunesSession starting at eof
						close access file theiTunesSession
					end tell
				end try
			end if
			set iTunesVolumeValues to get text items of iTunesVolumeValue
			set theVolumeCount to count iTunesVolumeValues
			set theCurrentVolume to get item theVolumeCount of iTunesVolumeValues
			set currentvolume to (theCurrentVolume + 0) as integer
			try
				set theSongName to do shell script "curl -vvv -m 2 -H \"Viewer-Only-Client: 1'\" \"http://" & myItunesHost & ":3689/ctrl-int/1/playstatusupdate?revision-number=1&session-id=" & mySessionID & "\" | python ~/Library/Preferences/iTunesRemote/decode.py | grep cann"
				set theArtist to do shell script "curl -vvv -m 2 -H \"Viewer-Only-Client: 1'\" \"http://" & myItunesHost & ":3689/ctrl-int/1/playstatusupdate?revision-number=1&session-id=" & mySessionID & "\" | python ~/Library/Preferences/iTunesRemote/decode.py | grep cana"
				set theAlbum to do shell script "curl -vvv -m 2 -H \"Viewer-Only-Client: 1'\" \"http://" & myItunesHost & ":3689/ctrl-int/1/playstatusupdate?revision-number=1&session-id=" & mySessionID & "\" | python ~/Library/Preferences/iTunesRemote/decode.py | grep canl"
			end try
			set AppleScript's text item delimiters to {"     "}
			do shell script "curl -vvv -m 2 -H \"Viewer-Only-Client: 1'\" \"http://" & myItunesHost & ":3689/ctrl-int/1/nowplayingartwork?mw=320&mh=320&session-id=" & mySessionID & "\" > /tmp/currentartwork.png"
			set theSongNameList to text items of theSongName
			set theSongNameCount to count theSongNameList
			set thisSong to item theSongNameCount of theSongNameList
			set theArtistList to text items of theArtist
			set theArtistCount to count theArtistList
			set thisArtist to item theArtistCount of theArtistList
			set theAlbumList to text items of theAlbum
			set theAlbumCount to count theAlbumList
			set thisAlbum to item theAlbumCount of theAlbumList
			tell current application
				theVolumeSlider's |setDoubleValue_|(currentvolume)
				songTitle's setStringValue_(thisSong)
				songArtist's setStringValue_(thisArtist)
				songAlbum's setStringValue_(thisAlbum)
				songTitle2's setStringValue_(thisSong)
				songArtist2's setStringValue_(thisArtist)
				songAlbum2's setStringValue_(thisAlbum)
				tell current application's NSImage to set theImage to alloc()'s initWithContentsOfFile_("/tmp/currentartwork.png")
				tell songArtwork to setImage_(theImage)
			end tell
			set AppleScript's text item delimiters to {""}
		end tell
	end refresh_
	
	on idleWrapper()
		try
			-- The following calls the "on idle" handler and triggers
			-- an error if that handler fails, or if it returns a
			-- non-numeric value:
			set idleTime to (0.0 + (idle))
		on error
			set idleTime to missing value
		end try
		if (idleTime is missing value) or (idleTime ≤ 0.0) then
			set idleTime to 30.0 -- AppleScript default for idle handler delay
		end if
		my performSelector_withObject_afterDelay_("idleWrapper", missing value, idleTime)
	end idleWrapper
	
	on idle
		set AppleScript's text item delimiters to {""}
		tell current application
			set destpath2 to path to preferences
			set destpath to destpath2 & "iTunesRemote" & ":" as string
			set AppleScript's text item delimiters to {"=="}
			try
				set iTunesVolumeValue to do shell script "curl -vvv -m 3 -H \"Viewer-Only-Client: 1'\" \"http://" & myItunesHost & ":3689/ctrl-int/1/getproperty?properties=dmcp.volume&session-id=" & mySessionID & "\" | python ~/Library/Preferences/iTunesRemote/decode.py | grep cmvo"
			on error
				try
					set theSessionValue to do shell script "curl -vvv -m 3 -H \"Viewer-Only-Client: 1\"  http://" & myItunesHost & ":3689/login?pairing-guid=0x0000000000000001 | python ~/Library/Preferences/iTunesRemote/decode.py | grep mlid"
				end try
				set AppleScript's text item delimiters to {"=="}
				tell application "Finder"
					set theSessionValues to get text items of theSessionValue
				end tell
				set theValCount to count theSessionValues
				set theSessionID to get item theValCount of theSessionValues
				set theUsedSessionID to trim(theSessionID)
				set AppleScript's text item delimiters to {""}
				set theiTunesSession to destpath & "com.iTunesRemote.itunessession.txt" as string
				tell application "Finder"
					try
						close access file theiTunesSession
					end try
					delay 2
					open for access file theiTunesSession with write permission
					set eof file theiTunesSession to 0
					write theUsedSessionID to file theiTunesSession starting at eof
					close access file theiTunesSession
				end tell
			end try
			set iTunesVolumeValues to get text items of iTunesVolumeValue
			set theVolumeCount to count iTunesVolumeValues
			set theCurrentVolume to get item theVolumeCount of iTunesVolumeValues
			set currentvolume to (theCurrentVolume + 0) as integer
			try
				set theSongName to do shell script "curl -vvv -m 2 -H \"Viewer-Only-Client: 1'\" \"http://" & myItunesHost & ":3689/ctrl-int/1/playstatusupdate?revision-number=1&session-id=" & mySessionID & "\" | python ~/Library/Preferences/iTunesRemote/decode.py | grep cann"
				set theArtist to do shell script "curl -vvv -m 2 -H \"Viewer-Only-Client: 1'\" \"http://" & myItunesHost & ":3689/ctrl-int/1/playstatusupdate?revision-number=1&session-id=" & mySessionID & "\" | python ~/Library/Preferences/iTunesRemote/decode.py | grep cana"
				set theAlbum to do shell script "curl -vvv -m 2 -H \"Viewer-Only-Client: 1'\" \"http://" & myItunesHost & ":3689/ctrl-int/1/playstatusupdate?revision-number=1&session-id=" & mySessionID & "\" | python ~/Library/Preferences/iTunesRemote/decode.py | grep canl"
			end try
			set AppleScript's text item delimiters to {"     "}
			do shell script "curl -vvv -m 2 -H \"Viewer-Only-Client: 1'\" \"http://" & myItunesHost & ":3689/ctrl-int/1/nowplayingartwork?mw=320&mh=320&session-id=" & mySessionID & "\" > /tmp/currentartwork.png"
			set theSongNameList to text items of theSongName
			set theSongNameCount to count theSongNameList
			set thisSong to item theSongNameCount of theSongNameList
			set theArtistList to text items of theArtist
			set theArtistCount to count theArtistList
			set thisArtist to item theArtistCount of theArtistList
			set theAlbumList to text items of theAlbum
			set theAlbumCount to count theAlbumList
			set thisAlbum to item theAlbumCount of theAlbumList
			tell current application
				theVolumeSlider's |setDoubleValue_|(currentvolume)
				songTitle's setStringValue_(thisSong)
				songArtist's setStringValue_(thisArtist)
				songAlbum's setStringValue_(thisAlbum)
				songTitle2's setStringValue_(thisSong)
				songArtist2's setStringValue_(thisArtist)
				songAlbum2's setStringValue_(thisAlbum)
				tell current application's NSImage to set theImage to alloc()'s initWithContentsOfFile_("/tmp/currentartwork.png")
				tell songArtwork to setImage_(theImage)
			end tell
			set AppleScript's text item delimiters to {""}
			return 3
		end tell
	end idle
end script