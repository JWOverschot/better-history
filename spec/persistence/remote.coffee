describe 'BH.Persistence.Remote', ->
  beforeEach ->
    @state =
      set: jasmine.createSpy('set')
    @ajax = jasmine.createSpy('ajax')
    @sync = new BH.Persistence.Remote '123123123', @ajax, @state

  describe '#performRequest', ->
    beforeEach ->
      @ajax.andCallFake (config) ->
        config.complete()

      spyOn(global, 'setTimeout').andCallFake (callback) ->
        callback()

    it 'sets the state as syncing', ->
      @sync.performRequest()
      expect(@state.set).toHaveBeenCalledWith(syncing: true)

    it 'sets the state as not syncing when complete', ->
      @sync.performRequest
        syncDelay: 0
      expect(@state.set).toHaveBeenCalledWith(syncing: false)

  describe '#share', ->
    describe 'when logged out', ->
      it 'calls to the logged out share endpoint with stringified tag data', ->
        @sync.share
          name: 'camping'
          site: [
            title: 'Camping the World'
            url: 'http://www.camping.com'
            datetime: 1231234
          ]

        expect(@ajax).toHaveBeenCalledWith
          url: 'http://api.better-history.com/share'
          type: 'POST'
          contentType: 'application/json'
          dataType: 'json'
          data: '{"url":"http://www.camping","title":"Camping the World","datetime":1231234,"tags":["camping","outdoors"]}'
          error: jasmine.any(Function)
          success: jasmine.any(Function)
          complete: jasmine.any(Function)

    describe 'when logged in', ->
      it 'calls to the logged in share endpoint with stringified tag data', ->
        @sync.share
          name: 'camping'
          site: [
            title: 'Camping the World'
            url: 'http://www.camping.com'
            datetime: 1231234
          ]

        expect(@ajax).toHaveBeenCalledWith
          url: 'http://api.better-history.com/user/share'
          type: 'POST'
          contentType: 'application/json'
          dataType: 'json'
          headers:
            authorization: '123123123'
          data: '{"url":"http://www.camping","title":"Camping the World","datetime":1231234,"tags":["camping","outdoors"]}'
          error: jasmine.any(Function)
          success: jasmine.any(Function)
          complete: jasmine.any(Function)
  describe '#updateSite', ->
    it 'calls to ajax with stringified site data', ->
      @sync.updateSite
        url: 'http://www.camping'
        title: 'Camping the World'
        datetime: 1231234
        tags: ['camping', 'outdoors']

      expect(@ajax).toHaveBeenCalledWith
        url: 'http://api.better-history.com/user/site'
        type: 'POST'
        contentType: 'application/json'
        dataType: 'text'
        headers:
          authorization: '123123123'
        data: '{"url":"http://www.camping","title":"Camping the World","datetime":1231234,"tags":["camping","outdoors"]}'
        error: jasmine.any(Function)
        success: jasmine.any(Function)
        complete: jasmine.any(Function)

  describe '#updateSites', ->
    it 'calls to ajax with stringified tag rename data', ->
      data = [{
        title: 'camping'
        url: 'http://www.camping.com'
        datetime: 123123123123
        image: 'favicon base64'
        tags: 'camping, outdoors'
      }, {
        title: 'cars'
        url: 'http://www.cars.com'
        datetime:123123123123
        image: 'favicon base64'
        tags: 'engines, cars, auto'
      }]

      @sync.updateSites data
      expect(@ajax).toHaveBeenCalledWith
        url: 'http://api.better-history.com/user/sites'
        type: 'POST'
        contentType: 'application/json'
        dataType: 'text'
        headers:
          authorization: '123123123'
        data: '[{"title":"camping","url":"http://www.camping.com","datetime":123123123123,"image":"favicon base64","tags":"camping, outdoors"},{"title":"cars","url":"http://www.cars.com","datetime":123123123123,"image":"favicon base64","tags":"engines, cars, auto"}]'
        error: jasmine.any(Function)
        success: jasmine.any(Function)
        complete: jasmine.any(Function)

  describe '#getSites', ->
    it 'calls to ajax to get all the sites', ->
      @sync.getSites()
      expect(@ajax).toHaveBeenCalledWith
        url: 'http://api.better-history.com/user/sites'
        type: 'GET'
        contentType: 'application/json'
        dataType: 'json'
        headers:
          authorization: '123123123'
        error: jasmine.any(Function)
        success: jasmine.any(Function)
        complete: jasmine.any(Function)

  describe '#renameTag', ->
    it 'calls to ajax with stringified tag rename data', ->
      @sync.renameTag('cooking', 'baking')
      expect(@ajax).toHaveBeenCalledWith
        url: 'http://api.better-history.com/user/tags/cooking/rename'
        type: 'PUT'
        contentType: 'application/json'
        dataType: 'text'
        headers:
          authorization: '123123123'
        data: '{"name":"baking"}'
        error: jasmine.any(Function)
        success: jasmine.any(Function)
        complete: jasmine.any(Function)

  describe '#deleteTag', ->
    it 'calls to ajax to delete a tag', ->
      @sync.deleteTag('cooking')
      expect(@ajax).toHaveBeenCalledWith
        url: 'http://api.better-history.com/user/tags/cooking'
        type: 'DELETE'
        contentType: 'application/json'
        dataType: 'text'
        headers:
          authorization: '123123123'
        error: jasmine.any(Function)
        success: jasmine.any(Function)
        complete: jasmine.any(Function)
