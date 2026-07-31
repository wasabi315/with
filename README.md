# with

Emulate [Koka's with statement](https://koka-lang.github.io/koka/doc/book.html#sec-with) using QualifiedDo.

```haskell
{-# LANGUAGE QualifiedDo #-}
{-# LANGUAGE UnboxedTuples #-}

import With
import Control.Exception
import Data.Foldable
import Text.Printf

forPair_ :: Applicative f => [(a, b)] -> (a -> b -> f ()) -> f ()
forPair_ ps f = for_ ps (\(a, b) -> f a b)

main = With.do
  -- ordinary monadic bind and sequencing
  s <- getLine
  print s
  -- with, without binding
  with (`finally` putStrLn "Bye!")
  -- with, binding one argument
  n <- with (for_ [0 :: Int .. 3])
  -- with, binding multiple arguments. use unboxed tuples
  (# k, v #) <- with (forPair_ [("foo", 1), ("bar", 2)])
  printf "n = %d, k = %s, v = %d\n" n k v
```
