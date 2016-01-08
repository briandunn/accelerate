module Accelerate where

-- IMPORTS
import Html exposing (..)
import Effects
import String
import Signal
import Time
import StartApp as StartApp

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
  round(200 + abs (point.x * 300))

-- VIEW

view address model =
  div [] [
    text <| toString model.currentPoint.x
  ]

inbox : Signal.Mailbox Action
inbox =
  Signal.mailbox NoOp

state : Signal Model
state =
  Signal.foldp update initialModel actions

sampledAcceleration : Signal Point
sampledAcceleration =
  Signal.sampleOn (Time.fps 30) acceleration

actions : Signal Action
actions =
  Signal.merge inbox.signal (Signal.map AddPoint sampledAcceleration)

main =
  Signal.map (view inbox.address) state
