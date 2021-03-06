module.exports =
  configDefaults:
    showHiddenFiles: false,
    numberOfConcurrentSshQueriesInOneConnection: 5,
    sshPrivateKeyPath: "~/.ssh/id_rsa",
    defaultSerializePath: "~/.atom/remoteEdit.json",
    uploadOnSave: true

  getView: ->
    MainView = require './main-view'
    @view ?= new MainView()

  activate: (state) ->
    @setupOpener()

    atom.workspaceView.command "remote-edit:show-open-files", =>
      @getView().showOpenFiles()

    atom.workspaceView.command "remote-edit:browse", =>
      @getView().browse()

    atom.workspaceView.command "remote-edit:new-host-sftp", =>
      @getView().newHost("sftp")

    atom.workspaceView.command "remote-edit:new-host-ftp", =>
      @getView().newHost("ftp")

    atom.workspaceView.command "remote-edit:clear-hosts", =>
      @getView().clearHosts()

  deactivate: ->
    @view?.destroy()

  setupOpener: ->
    atom.workspace.registerOpener (uriToOpen) ->
      url = require 'url'
      try
        {protocol, host, query} = url.parse(uriToOpen, true)
      catch error
        return
      return unless protocol is 'remote-edit:'

      if host is 'localfile'
        Q = require 'q'
        FileEditorView = require './view/file-editor-view'
        atom.project.open(query.path).then (editor) -> new FileEditorView(editor, uriToOpen)
      else
        return
