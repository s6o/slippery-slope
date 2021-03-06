module SlippyMap.Layer.Marker
    exposing
        ( Config
        , config
        , layer
        )

{-| A layer to display markers.

@docs Config, config, layer

-}

import SlippyMap.Events exposing (Event)
import SlippyMap.Geo.Location exposing (Location)
import SlippyMap.Layer as Layer exposing (Layer)
import SlippyMap.Map as Map exposing (Map)
import Svg exposing (Svg)
import Svg.Attributes
import VirtualDom


-- CONFIG


{-| Configuration for the layer.
-}
type Config marker msg
    = Config
        { location : marker -> Location
        , icon : marker -> Svg msg
        , toEvents : List (marker -> Event marker msg)
        }


{-| -}
config : (marker -> Location) -> (marker -> Svg msg) -> List (marker -> Event marker msg) -> Config marker msg
config toLocation toIcon toEvents =
    Config
        { location = toLocation
        , icon = toIcon
        , toEvents = toEvents
        }


{-| -}
layer : Config marker msg -> List marker -> Layer msg
layer config markers =
    Layer.marker
        |> Layer.custom (render config markers)


{-| -}
render : Config marker msg -> List marker -> Map msg -> Svg msg
render ((Config { location }) as config) markers map =
    let
        locatedMarkers =
            List.map
                (\marker -> ( location marker, marker ))
                markers

        locatedMarkersFiltered =
            locatedMarkers
    in
    Svg.svg
        [ -- Important for touch pinching
          Svg.Attributes.pointerEvents "none"
        , Svg.Attributes.width "100%"
        , Svg.Attributes.height "100%"
        , Svg.Attributes.style "position: absolute;"
        ]
        (List.map (marker config map) locatedMarkersFiltered)


marker : Config marker msg -> Map msg -> ( Location, marker ) -> Svg msg
marker (Config config) map ( location, marker ) =
    let
        markerPoint =
            Map.locationToScreenPoint map location

        events =
            List.map
                (\toEvent ->
                    let
                        { name, toDecoder } =
                            toEvent marker
                    in
                    VirtualDom.onWithOptions name
                        { stopPropagation = True
                        , preventDefault = False
                        }
                        (toDecoder marker)
                )
                config.toEvents
    in
    Svg.g
        (Svg.Attributes.transform
            ("translate("
                ++ toString markerPoint.x
                ++ " "
                ++ toString markerPoint.y
                ++ ")"
            )
            :: (Svg.Attributes.pointerEvents "auto" :: events)
        )
        [ config.icon marker ]
