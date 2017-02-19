'use strict';

exports.__esModule = true;
exports.clearTracks = undefined;

var _autoAdvance = require('./auto-advance.js');

/**
 * Removes all remote text tracks from a player.
 *
 * @param  {Player} player
 */
var clearTracks = function clearTracks(player) {
  var tracks = player.remoteTextTracks();
  var i = tracks && tracks.length || 0;

  // This uses a `while` loop rather than `forEach` because the
  // `TextTrackList` object is a live DOM list (not an array).
  while (i--) {
    player.removeRemoteTextTrack(tracks[i]);
  }
};

/**
 * Plays an item on a player's playlist.
 *
 * @param  {Player} player
 * @param  {Number} delay
 *         The number of seconds to wait before each auto-advance.
 *
 * @param  {Object} item
 *         A source from the playlist.
 *
 * @return {Player}
 */
var playItem = function playItem(player, delay, item) {
  var replay = !player.paused() || player.ended();

  player.trigger('beforeplaylistitem', item);
  player.poster(item.poster || '');
  player.src(item.sources);
  clearTracks(player);
  (item.textTracks || []).forEach(player.addRemoteTextTrack.bind(player));
  player.trigger('playlistitem', item);

  if (replay) {
    player.play();
  }

  (0, _autoAdvance.setup)(player, delay);

  return player;
};

exports['default'] = playItem;
exports.clearTracks = clearTracks;