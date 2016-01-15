module Accelerate where

-- IMPORTS
import Graphics.Collage exposing (..)
import Graphics.Element exposing (..)
import Graphics.Input exposing (button)
import Color
import Signal
import Time exposing (Time)
import Text
import Window

type alias Acceleration = {x:Float, y:Float, z:Float}
type alias Note = Int

-- PORTS
port acceleration : Signal Acceleration
port note : Signal Note
port note =
  Signal.map .currentNote state

port mute : Signal Bool
port mute =
  Signal.map .mute state

-- MODEL
type alias Model =
  { currentNote : Note
  , mute : Bool
  , accelerations : List Acceleration
  }

initialModel : Model
initialModel =
  { currentNote = 0
  , accelerations = []
  , mute = True
  }

type Action = NoOp | AddAcceleration Acceleration | Click

update : Action -> Model -> Model
update action model =
  case action of
    NoOp ->
      model

    Click ->
      { model | mute = not model.mute }

    AddAcceleration acceleration ->
      { model | accelerations = List.take 30 (acceleration :: model.accelerations)
              , currentNote   = accelerationToNote acceleration }

accelerationToNote : Acceleration -> Note
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
     layers
       [  collage w h (List.indexedMap drawCircle model.accelerations)
       ,  button (Signal.message inbox.address Click) (if model.mute then "LISTEN" else "SHUTUP")
       ]

inbox : Signal.Mailbox Action
inbox =
  Signal.mailbox NoOp

actions : Signal Action
actions =
  Signal.merge inbox.signal (Signal.map AddAcceleration (Signal.sampleOn (Time.fps 30) acceleration))

state : Signal Model
state =
  Signal.foldp update initialModel actions

main : Signal Element
main =
    Signal.map2 view Window.dimensions state

