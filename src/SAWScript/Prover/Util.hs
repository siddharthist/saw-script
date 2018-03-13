module SAWScript.Prover.Util where

import qualified Data.AIG as AIG
import qualified Data.ABC.GIA as GIA

import Verifier.SAW.SharedTerm
import Verifier.SAW.FiniteValue

import qualified Cryptol.TypeCheck.AST as C
import Cryptol.Utils.PP (pretty)


{-
checkTerm :: SharedContext -> Term -> 
checkTerm sc t0 =
  do TypedTerm schema t <-
        mkTypedTerm sc =<< rewriteEqs sc =<< bindAllExts sc t0
     checkBooleanSchema schema
     tp <- scWhnf sc =<< scTypeOf sc t
     let (args, _) = asPiList tp
         argNames = map fst args
-}


-- | Is this a bool, or something that returns bool.
checkBooleanType :: C.Type -> IO ()
checkBooleanType ty
  | C.tIsBit ty                 = return ()
  | Just (_,ty') <- C.tIsFun ty = checkBooleanType ty'
  | otherwise = fail ("Invalid non-boolean type: " ++ pretty ty)

-- | Make sure that this schema is monomorphic, and either boolean,
-- or something that returns a boolean.
checkBooleanSchema :: C.Schema -> IO ()
checkBooleanSchema (C.Forall [] [] t) = checkBooleanType t
checkBooleanSchema s = fail ("Invalid polymorphic type: " ++ pretty s)

bindAllExts :: SharedContext -> Term -> IO Term
bindAllExts sc body = scAbstractExts sc (getAllExts body) body

liftCexBB :: [FiniteType] -> [Bool] -> Either String [FiniteValue]
liftCexBB tys bs =
  case readFiniteValues tys bs of
    Nothing -> Left "Failed to lift counterexample"
    Just fvs -> Right fvs

-- | The 'AIG.Proxy' used by SAWScript.
sawProxy :: AIG.Proxy GIA.Lit GIA.GIA
sawProxy = GIA.proxy


