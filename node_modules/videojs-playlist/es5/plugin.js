'use strict';

exports.__esModule = true;

var _video = require('video.js');

var _video2 = _interopRequireDefault(_video);

var _playlistMaker = require('./playlist-maker');

var _playlistMaker2 = _interopRequireDefault(_playlistMaker);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { 'default': obj }; }

// Video.js 5/6 cross-compatible.
var registerPlugin = _video2['default'].registerPlugin || _video2['default'].plugin;

/**
 * The video.js playlist plugin. Invokes the playlist-maker to create a
 * playlist function on the specific player.
 *
 * @param {Array} list
 */
var plugin = function plugin(list, item) {
  (0, _playlistMaker2['default'])(this, list, item);
};

registerPlugin('playlist', plugin);

exports['default'] = plugin;