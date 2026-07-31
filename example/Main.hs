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

newtype Assoc a b = Assoc [(a, b)]

forWithKey_ :: (Applicative m) => Assoc a b -> (a -> b -> m ()) -> m ()
forWithKey_ (Assoc xs) f = for_ xs (uncurry f)

example4 = With.do
  (# k, v #) <- with do forWithKey_ $ Assoc [(1 :: Int, "one"), (2, "two")]
  printf "key: %d, value: %s\n" k v :: IO ()

main = With.do
  -- ordinary monadic bind and sequencing
  s <- getLine
  print s
  -- with, without binding
  with (`finally` putStrLn "Bye!")
  -- with, binding one argument
  n <- with do for_ [0 :: Int .. 3]
  -- with, binding multiple arguments
  (# k, v #) <- with do forWithKey_ $ Assoc [("foo", 1), ("bar", 2)]
  printf "n = %d, k = %s, v = %d\n" n k v
