/**
    Written by Akinyele Akintola-Febrissy

    This is a very little node.js script that takes in SRT files and converts
    them to VTT file. The hard part (the actual conversion) was taken from here:

    Credits to: https://github.com/silviapfeiffer/silviapfeiffer.github.io

    This is part of my Tanoshimu project but I do not claim this algorithm (the
    actual conversion part) to be mine.

    Setup:
    $ npm install fs
    $ node srttovtt.js [folder (default = current folder)] [-ext (extension - optional)]

    Example: You want to convert all SRT files located on "videos/srt". You also
    want to filter all ".srt" files.

    $ node srttovtt.js videos/srt -ext srt

    All files will be saving under the folder videos/srt/*.srt.

    Warning: this script may be a little slow, espacially if you don't add a
    file extension filter.
*/

var currentFolder = '.';
const fs = require('fs');
var extension = '';

process.argv.forEach(function (val, index, array) {
  if (index == 2) currentFolder = val;
  if (val == "-ext") {
    if (index < array.length) {
       extension = array[index+1];
    }
  }
});

fs.readdir(currentFolder, function(err, files) {
  [].forEach.call(files, function(file) {
    fs.readFile(currentFolder + "/" + file, 'utf8', function(err, data) {
       try {
        if (extension) {
           if (!file.endsWith(extension)) {
              return;
           }
        }
        new_data = srt2webvtt(data);
        new_filename = file.split('.' + extension);
        if (new_filename.length > 1) {
           new_filename.pop();
           new_filename = new_filename.join('');
        } else {
           new_filename = new_filename[0];
        }
        new_filename = new_filename.concat('.vtt');
        new_filename = currentFolder + "/" + new_filename;
        fs.writeFileSync(new_filename, new_data, function(err) {
            if (err) {
                console.error("We couldn't write the file " + new_filename + ": ");
                console.error(err);
            }
        });
       } catch (e) {
        console.log("Ignoring " + file + "...");
       }
    });
  });
});

function srt2webvtt(data) {
  // remove dos newlines
  var srt = data.replace(/\r+/g, '');
  // trim white space start and end
  srt = srt.replace(/^\s+|\s+$/g, '');

  // get cues
  var cuelist = srt.split('\n\n');
  var result = "";

  if (cuelist.length > 0) {
    result += "WEBVTT\n\n";
    for (var i = 0; i < cuelist.length; i=i+1) {
      result += convertSrtCue(cuelist[i]);
    }
  }
  
  return result;
}

function convertSrtCue(caption) {
  // remove all html tags for security reasons
  //srt = srt.replace(/<[a-zA-Z\/][^>]*>/g, ''); 
  
  var cue = "";
  var s = caption.split(/\n/);
  while (s.length > 3) {
    s[2] += '\n' + s.pop();
  }

  var line = 0;
  
  // detect identifier
  if (!s[0].match(/\d+:\d+:\d+/) && s[1].match(/\d+:\d+:\d+/)) {
    cue += s[0].match(/\w+/) + "\n";
    line += 1;
  }
  
  // get time strings
  if (s[line].match(/\d+:\d+:\d+/)) {
    // convert time string
    var m = s[1].match(/(\d+):(\d+):(\d+)(?:,(\d+))?\s*--?>\s*(\d+):(\d+):(\d+)(?:,(\d+))?/);
    if (m) {
      cue += m[1]+":"+m[2]+":"+m[3]+"."+m[4]+" --> "
            +m[5]+":"+m[6]+":"+m[7]+"."+m[8]+"\n";
      line += 1;
    } else {
      // Unrecognized timestring
      return "";
    }
  } else {
    // file format error or comment lines
    return "";
  }
  
  // get cue text
  if (s[line]) {
    cue += s[line] + "\n\n";
  }

  return cue;
}