location = undefined
map = undefined
travelMode = "WALKING"
distanceByMode =
  WALKING: 800
  BICYCLING: 2000
  DRIVING: 10000

bounsByMode =
  WALKING: 15
  BICYCLING: 13
  DRIVING: 12

#現在位置
existShops = {}
current_lat = null
current_lng = null

#ルート検索サービス
directionsService = new google.maps.DirectionsService()
directionsDisplay = new google.maps.DirectionsRenderer()

#ルート検索オブジェクト
map_active_shopid = null
map_markers = {}
route_result = undefined
setTrabelMode = (mode) ->
  travelMode = mode
  centerLatLng = new google.maps.LatLng(current_lat, current_lng)
  map.setCenter centerLatLng, 10
  map.setZoom bounsByMode[travelMode]

#緯度経度取得
updateCurrentLocation = (callback, error) ->
  #Androidバージョンの判定
  agent = navigator.userAgent
  if agent.search(/Android 1.5;/) isnt -1 or agent.search(/Android 1.6;/) isnt -1
    gpsVersion = "1.5"
    gps = google.gears.factory.create("beta.geolocation")
  else
    gpsVersion = "other"
    gps = navigator.geolocation
  gps.getCurrentPosition callback, error #, 0
  true

###
マップの作成
###
mapInitialize = (elmId, initOption) ->
  appResize()
  initOption.zoom = bounsByMode[travelMode]  if typeof initOption.zoom is "undefined"
  myOptions =
    zoom: initOption.zoom
    mapTypeId: google.maps.MapTypeId.ROADMAP
    # disableDefaultUI: true
    navigationControl: true
    draggable: true
    navigationControlOptions:
      style: google.maps.NavigationControlStyle.SMALL
  map = new google.maps.Map(document.getElementById(elmId), myOptions)
  makeShopMakers initOption  unless typeof initOption.markers is "undefined"
  google.maps.event.addListener map, "idle", initOption.idle  unless typeof initOption.idle is "undefined"

#店舗マーカ作成
makeShopMakers = (initOptions) ->
  markers = initOptions.markers
  jQuery.each markers, (shopid, shop) ->
    if existShops[shop.url] < 1 or existShops[shop.url] is `undefined`
      existShops[shop.url] = 1
      lagLng = getWorldGeodetic(shop.lat, shop.lng)
      marker = new google.maps.Marker(
        position: new google.maps.LatLng(lagLng.lat, lagLng.lng)
        map: map
        shopid: shopid
        shop: shop
      )
      map_markers[shopid] = marker

setActiveShop = (activeshopid) ->
  # jQuery.each map_markers, (shopid, marker) ->
  #   unless shopid is activeshopid
  #     unless marker.shop.is_opening is "yes"
  #       map_markers[shopid].setIcon "/smartphone/sp-common/images/mapicon_store_close.png"
  #     else
  #       map_markers[shopid].setIcon "/smartphone/sp-common/images/mapicon_store.png"
  console.log activeshopid
  # unless typeof map_markers[activeshopid] is "undefined"
  #   console.log typeof map_markers[activeshopid]
  #   map_markers[activeshopid].setIcon "/smartphone/sp-common/images/mapicon_store_active.png"
  map_active_shopid = activeshopid

routeDisplay = ->
  route_shop_id = current_shop_id
  directionsDisplay.setMap map
  directionsDisplay.setDirections route_result
  directionsDisplay.setOptions suppressMarkers: true
  closeOverlay "#storedetail"

#マップが動いた時の再読み込み処理
mapMoveEvent = ->

  #中心座標
  centerLocation = map.getCenter()
  centerLat = centerLocation.lat()
  centerLng = centerLocation.lng()

  #北東座標(右上)
  northeastLocation = map.getBounds().getNorthEast()
  northeastLat = northeastLocation.lat()
  northeastLng = northeastLocation.lng()

  #南西座標(左下)
  shouthwestLocation = map.getBounds().getSouthWest()
  shouthwestLat = shouthwestLocation.lat()
  shouthwestLng = shouthwestLocation.lng()

  #マップ移動時のajax処理
  jQuery.ajax
    url: "/stores.json"
    data:
      center:
        lat: centerLat
        lng: centerLng

      northeast:
        lat: northeastLat
        lng: northeastLng

      thouthwest:
        lat: shouthwestLat
        lng: northeastLng

      ignoreshopid: 75

    global: false
    dataType: "json"
    success: (shops, dataType) ->
      shopcount = 0

      #マップの描画
      jQuery.each shops, (shopid, shop) ->
        shopcount++
        shops[shopid] = shop

      unless shopcount is 0

        #店舗数が0なら何もしない

        #描画完了
        makerOption =
          markers: shops

        makeShopMakers makerOption
        jQuery("#loader").hide()
        jQuery("#search_result").show()

    error: (XMLHttpRequest, textStatus, errorThrown) ->


appResize = ->
  jQuery("#maparea").css
    width: "100%"
    height: "#{$(window).height() - 200}px"
    "text-align": "center"
    "margin-top": "-20px"

jQuery(document).ready (->
  #店舗位置
  current_lat = 35.6911512944
  current_lng = 139.757319595

  #近隣店舗の取得
  jQuery.ajax
    url: "/stores.json"
    data:
      center:
        lat: current_lat
        lng: current_lng
      distance: distanceByMode[travelMode]
      shopid: 75
      ignoreshopid: 75
    global: false
    dataType: "json"
    success: (data, dataType) ->
      shopcount = 0
      shops = {}
      #マップの描画
      jQuery.each data, (shopid, shop) ->
        shopcount++
        shops[shopid] = shop
      #描画完了
      initializeOption =
        markers: shops
        currentLat: current_lat
        currentLng: current_lng
        idle: mapMoveEvent
        zoom: 17
        # icon_center: "/smartphone/sp-common/images/mapicon_store_active.png"
        # icon_shop: "/smartphone/sp-common/images/mapicon_store.png"

      mapInitialize "maparea", initializeOption
      centerLatLng = new google.maps.LatLng(current_lat, current_lng)
      map.setCenter centerLatLng, 18
      map.setOptions
        navigationControl: false
        navigationControlOptions: false
        draggable: false

      jQuery("#loader").hide()
      jQuery("#search_result").show()

    #Ajax通信エラー
    error: (XMLHttpRequest, textStatus, errorThrown) ->
      jQuery("#loader").hide()
      jQuery("#search_resulterror").show()

#マップの描画処理
), handleError = (positionError) ->
  #/GPS位置情報取得エラー処理
  jQuery("#loader").hide()
  jQuery("#search_locationerror").show()

getWorldGeodetic = (x, y)->
  y = y / 3600
  x = x / 3600
  resLat = (y - y * 0.00010695 + x * 0.000017464 + 0.0046017)
  resLng = (x - y * 0.000046038 - x * 0.000083043 + 0.010040)
  {
    lat: resLat
    lng: resLng
  }

