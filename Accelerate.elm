module Accelerate where

-- IMPORTS
import Graphics.Collage exposing (..)
import Graphics.Element exposing (..)
import Color
import Signal
import Time
import Text
import Window

type alias Point = {x:Float, y:Float, z:Float}
type alias Note = Int

-- PORTS
port acceleration : Signal Point
port note : Signal Note
port note =
  Signal.map .currentNote state

-- MODEL
type alias Model =
  { currentNote : Note
  , currentPoint : Point
  }

initialModel : Model
initialModel =
  { currentNote = 0
  , currentPoint = { x = 0, y = 0, z = 0 }
  }

type Action = NoOp | AddPoint Point

update : Action -> Model -> Model
update action model =
  case action of
    NoOp ->
      model

    AddPoint point ->
      { model | currentPoint = point, currentNote = pointToNote point }

pointToNote : Point -> Note
pointToNote point =
  round(200 + abs ((point.x + point.y + point.z) * 100))

-- VIEW

view : (Int,Int) -> Model -> Element
view (w,h) model =
  let
    c = circle ( model.currentPoint.z * (toFloat w))
      |> filled Color.red
      |> move (model.currentPoint.x * (toFloat w), model.currentPoint.y * (toFloat h))
  in
    collage w h [c]

inbox : Signal.Mailbox Action
inbox =
  Signal.mailbox NoOp

actions : Signal Action
actions =
  Signal.merge inbox.signal (Signal.map AddPoint sampledAcceleration)

state : Signal Model
state =
  Signal.foldp update initialModel actions

sampledAcceleration : Signal Point
sampledAcceleration =
  Signal.sampleOn (Time.fps 30) acceleration

main : Signal Element
main =
    Signal.map2 view Window.dimensions state

