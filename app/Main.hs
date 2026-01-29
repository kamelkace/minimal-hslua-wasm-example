{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications  #-}
import Control.Monad (void)
import Data.Version (makeVersion)
import HsLua
import Prelude

-- | Factorial function.
factorial :: DocumentedFunction e
factorial = defun "factorial"
  ### liftPure (\n -> product [1..n] :: Prelude.Integer)
  --                 get arg      type of arg      name  description
  <#> parameter      peekIntegral "integer"        "n"   "input number"
  =#> functionResult pushIntegral "integer|string"       "factorial of n"
  #? "Computes the factorial of an integer."
  `since` makeVersion [1,0,0]

main :: IO ()
main = run @HsLua.Exception $ do
  openlibs
  pushDocumentedFunction factorial *> setglobal "factorial"
  -- run a script
  void . dostring $ mconcat
    [ "print(' 5! =', factorial(5), type(factorial(5)))\n"
    , "print('30! =', factorial(30), type(factorial(30)))\n"
    , "print('Oh, and hello from Lua, world!')\n"
    ]
