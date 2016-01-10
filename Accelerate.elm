module Accelerate where

-- IMPORTS
import Graphics.Collage exposing (..)
import Graphics.Element exposing (..)
import Color
import Signal
import Time exposing (Time)
import Text
import Window

type alias AccelerometerReading = {x:Float, y:Float, z:Float}
type alias Acceleration = (Time, AccelerometerReading)
type alias Note = Int

-- PORTS
port acceleration : Signal AccelerometerReading
port note : Signal Note
port note =
  Signal.map .currentNote state

-- MODEL
type alias Model =
  { currentNote : Note
  , currentAcceleration : Acceleration
  , accelerations : List Acceleration
  }

initialModel : Model
initialModel =
  { currentNote = 0
  , accelerations = []
  , currentAcceleration =  (0, { x = 0, y = 0, z = 0 })
  }

type Action = NoOp | AddAcceleration Acceleration

update : Action -> Model -> Model
update action model =
  case action of
    NoOp ->
      model

    AddAcceleration acceleration ->
      { model | currentAcceleration = acceleration
              , accelerations       = List.take 30 (acceleration :: model.accelerations)
              , currentNote         = accelerationToNote (snd acceleration) }

accelerationToNote : AccelerometerReading -> Note
accelerationToNote acceleration =
  round(200 + abs ((acceleration.x + acceleration.y + acceleration.z) * 100))

-- VIEW

view : (Int,Int) -> Model -> Element
view (w,h) model =
  let
    drawCircle a {x,y,z} = circle ((z / 2) * (toFloat w))
      |> filled (Color.rgba 128 0 0 ((toFloat (30 - a)) / 30))
      |> move (x * (toFloat w), y * (toFloat h))
  in
    collage w h (List.indexedMap drawCircle (List.map snd model.accelerations))

inbox : Signal.Mailbox Action
inbox =
  Signal.mailbox NoOp

actions : Signal Action
actions =
  Signal.merge inbox.signal (Signal.map AddAcceleration (Time.timestamp (Signal.sampleOn (Time.fps 30) acceleration)))

state : Signal Model
state =
  Signal.foldp update initialModel actions

main : Signal Element
main =
    Signal.map2 view Window.dimensions state

