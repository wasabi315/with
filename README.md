# with

QualifiedDo notation for mixing monadic actions with [Koka-style with statements](https://koka-lang.github.io/koka/doc/book.html#sec-with).

```haskell
{-# LANGUAGE QualifiedDo #-}
{-# LANGUAGE UnboxedTuples #-}

import With
import Control.Exception
import Data.Foldable
import Text.Printf

forPair_ :: (Applicative m) => [(a, b)] -> (a -> b -> m ()) -> m ()
forPair_ xs f = for_ xs (uncurry f)

main = With.do
  -- ordinary monadic bind and sequencing
  s <- getLine
  print s
  -- with, without binding
  (# #) <- (`finally` putStrLn "Bye!")
  -- with, binding one argument
  (# n #) <- for_ [0 :: Int .. 3]
  -- with, binding multiple arguments
  (# k, v #) <- forPair_ [("foo", 1), ("bar", 2)]
  printf "n = %d, k = %s, v = %d\n" n k v
```
