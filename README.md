# with-do

QualifiedDo notation for mixing monadic actions with [Koka-style with statements](https://koka-lang.github.io/koka/doc/book.html#sec-with).
Existing `do` blocks can generally be replaced with `With.do` unchanged.

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
  with (`finally` putStrLn "Bye!")
  -- with, binding one argument
  n <- with (for_ [0 :: Int .. 3])
  -- with, binding multiple arguments
  (# k, v #) <- with (forPair_ [("foo", 1), ("bar", 2)])
  printf "n = %d, k = %s, v = %d\n" n k v
```

With statements can be abstracted into reusable helper functions:

```haskell
defer :: IO () -> With (IO a -> IO a)
defer cleanup = with (`finally` cleanup)

main = With.do
  defer (putStrLn "Bye!")
  putStrLn "Hello!"
```
