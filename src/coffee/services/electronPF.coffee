angular.module('electron', []).provider 'Platform', () ->

  storage = require('electron-json-storage')

  ###*
   Platform api wrapper for electron app.
   @class Platform
  ###
  class Platform

    # key on storage
    SELECTED_PROJECT: "SELECTED_PROJECT"

    ###*
     @constructor
     @param {Object} $q - Service for Promise.
     @param {Object} $log - Service for Log.
    ###
    constructor: (@$q, @$log) ->

    ###*
     @typedef LoadedObject
     @property {Object} Loaded object.
    ###

    ###*
     Load data from storage area.
     @param {String} key - Key of data.
     @returns {Promise.<LoadedObject>} A promise for result of loading .
    ###
    load: (key) =>
      deferred = @$q.defer()

      storage.get key, (err, local) =>
        if not err?
          @$log.info key + ' loaded.'
          @$log.debug local
          deferred.resolve(local[key])
        else
          @$log.debug err
          deferred.reject()

      return deferred.promise

    ###*
     Save data to storage area.
     @param {String} key - Key of data.
     @param {Object} value - Value which to be saved.
     @return {Promise.<undefined>} A promise for result of saving.
    ###
    save: (key, value) =>
      deferred = @$q.defer()

      storage.set key, value, (err) =>
        if err?
          @$log.info key + ' failed to save.'
          deferred.reject()
        else
          @$log.info key + ' saved to local.'
          @$log.debug value
          deferred.resolve()

      return deferred.promise

    ###*
     Save data to storage `local` area. Same as `save()`.
     @param {String} key - Key of data.
     @param {Object} value - Value which to be saved.
     @return {Promise.<undefined>} A promise for result of saving.
    ###
    saveLocal: (key, value) =>
      return @save(key, value)

    ###*
     Clear data from storage area.
     @return {Promise.<undefined>} A promise for result.
    ###
    clear: () =>
      deferred = @$q.defer()
      storage.clear (err) ->
        if err?
          deferred.reject()
        else
          deferred.resolve()
      return deferred.promise

    ###*
     Gets the system locale.
     @return {String} language
     {@link http://electron.atom.io/docs/api/locales/}
    ###
    getLanguage: () ->
      lang = require('electron').remote.app.getLocale()
      @$log.debug("Language: " + lang)
      return lang

    ###*
     Show the application window.
    ###
    showAppWindow: () =>
      win = require('electron').remote.getCurrentWindow()
      win.show()


    ###*
     Notification namespace.
     @namespace
    ###
    notifications:

      ###*
       @typedef {object} NotificationOptions
       @see {@link https://developer.chrome.com/apps/notifications#type-NotificationOptions}
      ###

      ###*
       @callback createCallback
       @param {string} notificationId
      ###

      ###*
       Creates and displays a notification.
       @param {string} [notificationId] - Identifier of the notification. If not set or empty, an ID will automatically be generated.
       @param {NotificationOptions} options - Contents of the notification.
       @param {createCallback} [callback] - Returns the notification id (either supplied or generated) that represents the created notification.
      ###
      create: (notificationId, options, callback) =>
        chrome.notifications.create(notificationId, options, callback)

      ###*
       @callback clearCallback
       @param {bool} wasCleared
      ###

      ###*
       Clears the specified notification.
       @param {string} notificationId - The id of the notification to be cleared.
       @param {clearCallback} [callback] - Called to indicate whether a matching notification existed.
      ###
      clear: (notificationId, callback) =>
        chrome.notifications.clear(notificationId, callback)

      ###*
       @callback onClickedListener
       @param {string} notificationId
      ###

      ###*
       Add on clicked lister to notification.
       @param {onClickedListener} listener - be called when the user clicked in a non-button area of the notification.
      ###
      addOnClickedListener: (listener) =>
        chrome.notifications.onClicked.addListener(listener)


  return {
    getLanguage: () -> return require('electron').remote.app.getLocale()
    $get: ($q, $log) -> return new Platform($q, $log)
  }