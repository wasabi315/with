{-# LANGUAGE BlockArguments #-}
{-# LANGUAGE QualifiedDo #-}
{-# LANGUAGE UnboxedTuples #-}

module Main where

import Control.Exception
import Control.Monad.IO.Class
import Data.Foldable
import System.IO
import Text.Printf
import With

--------------------------------------------------------------------------------

twice m = m *> m

example1 = With.do
  with twice
  with twice
  putStrLn "hi"

example1' :: (MonadIO m) => m ()
example1' = With.do
  with twice
  with twice
  liftIO $ putStrLn "hi"

example2 = With.do
  x <- with do for_ [1 .. 10]
  print x

data Oops = Oops deriving (Show)

instance Exception Oops

example3 = With.do
  with (`finally` putStrLn "exiting..")
  putStrLn "entering.."
  n <- throwIO Oops
  pure $ n + 42

forPair_ :: (Applicative m) => [(a, b)] -> (a -> b -> m ()) -> m ()
forPair_ xs f = for_ xs (uncurry f)

main = With.do
  -- ordinary monadic bind and sequencing
  s <- getLine
  print s
  -- with, without binding
  with (`finally` putStrLn "Bye!")
  -- with, binding one argument
  n <- with (for_ [0 :: Int .. 3])
  -- with, binding multiple arguments
  (# k, v #) <- with (forPair_ [("foo", 1), ("bar", 2)])
  printf "n = %d, k = %s, v = %d\n" n k v
