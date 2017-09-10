module SlippyMap.Map.Msg
    exposing
        ( DragMsg(..)
        , Msg(..)
        , PinchMsg(..)
        )

import Keyboard exposing (KeyCode)
import Mouse exposing (Position)
import SlippyMap.Geo.Point as Point exposing (Point)
import SlippyMap.Map.Types as Types exposing (Focus)
import Time exposing (Time)


{-| -}
type Msg
    = ZoomIn
    | ZoomOut
    | ZoomInAround Point
    | ZoomByAround Float Point
    | DragMsg DragMsg
    | PinchMsg PinchMsg
    | SetFocus Focus
    | KeyboardNavigation KeyCode
    | Tick Time


{-| -}
type DragMsg
    = DragStart Position
    | DragAt Position
    | DragEnd Position


{-| -}
type PinchMsg
    = PinchStart ( Position, Position )
    | PinchAt ( Position, Position )
    | PinchEnd ( Position, Position )
