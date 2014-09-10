{-# LANGUAGE OverloadedStrings, NoMonomorphismRestriction, GADTs, TemplateHaskell #-}
module Main where



import Control.Applicative
import Control.Lens
import Data.ByteString (ByteString)
import Data.Text (Text)
import Data.Maybe (fromMaybe)
import qualified Data.Map as M
import Snap (Handler, method, Method(..), writeText, writeBS,
                getParam, SnapletInit, makeSnaplet, addRoutes,
                route, liftIO, void)
import qualified Snap as Snap
import Control.Concurrent.Async (async)
import Control.Concurrent.MVar (MVar, newEmptyMVar, tryPutMVar, tryTakeMVar, isEmptyMVar)
import qualified System.IO.Streams as Stream
import qualified System.IO.Streams.Concurrent as Stream
import System.Exit (exitSuccess, exitFailure)
import Snap.Test.BDD

import Site
import HomeTest

main :: IO ()
main = do
  (inp, out) <- Stream.makeChanPipe
  runSnapTests defaultConfig { reportGenerators = [streamReport out, consoleReport] }
                       (route routes)
                       app
                       homeTests
  res <- Stream.toList inp
  if length (filter isFailing res) == 0
     then exitSuccess
     else exitFailure
 where streamReport out results = do res <- Stream.read results
                                     case res of
                                       Nothing -> Stream.write Nothing out
                                       Just r -> do
                                         Stream.write (Just r) out
                                         streamReport out results
       isFailing (TestFail _) = True
       isFailing (TestError _) = True
       isFailing _ = False
