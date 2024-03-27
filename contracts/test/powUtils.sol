// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

// Library was taken from https://github.com/barakman/solidity-math-utils
// It consists of Math.sol && IntegralMath.sol.
//
// note: FractionalMath.sol L#7: 4 -changed to-> 40 to allow for the desired
//       exponential calculation.

uint256 constant MAX_VAL = type(uint256).max;

// reverts on overflow
function safeAdd(uint256 x, uint256 y) pure returns (uint256) {
  return x + y;
}

// does not revert on overflow
function unsafeAdd(uint256 x, uint256 y) pure returns (uint256) {
  unchecked {
    return x + y;
  }
}

// does not revert on overflow
function unsafeSub(uint256 x, uint256 y) pure returns (uint256) {
  unchecked {
    return x - y;
  }
}

// does not revert on overflow
function unsafeMul(uint256 x, uint256 y) pure returns (uint256) {
  unchecked {
    return x * y;
  }
}

// does not overflow
function mulModMax(uint256 x, uint256 y) pure returns (uint256) {
  unchecked {
    return mulmod(x, y, MAX_VAL);
  }
}

// does not overflow
function mulMod(uint256 x, uint256 y, uint256 z) pure returns (uint256) {
  unchecked {
    return mulmod(x, y, z);
  }
}

library IntegralMath {
  /**
   * @dev Compute the largest integer smaller than or equal to the binary logarithm of `n`
   */
  function floorLog2(uint256 n) internal pure returns (uint8) {
    unchecked {
      uint8 res = 0;

      if (n < 256) {
        // at most 8 iterations
        while (n > 1) {
          n >>= 1;
          res += 1;
        }
      } else {
        // exactly 8 iterations
        for (uint8 s = 128; s > 0; s >>= 1) {
          if (n >= 1 << s) {
            n >>= s;
            res |= s;
          }
        }
      }

      return res;
    }
  }

  /**
   * @dev Compute the largest integer smaller than or equal to the square root of `n`
   */
  function floorSqrt(uint256 n) internal pure returns (uint256) {
    unchecked {
      if (n > 0) {
        uint256 x = n / 2 + 1;
        uint256 y = (x + n / x) / 2;
        while (x > y) {
          x = y;
          y = (x + n / x) / 2;
        }
        return x;
      }
      return 0;
    }
  }

  /**
   * @dev Compute the smallest integer larger than or equal to the square root of `n`
   */
  function ceilSqrt(uint256 n) internal pure returns (uint256) {
    unchecked {
      uint256 x = floorSqrt(n);
      return x ** 2 == n ? x : x + 1;
    }
  }

  /**
   * @dev Compute the largest integer smaller than or equal to the cubic root of `n`
   */
  function floorCbrt(uint256 n) internal pure returns (uint256) {
    unchecked {
      uint256 x = 0;
      for (uint256 y = 1 << 255; y > 0; y >>= 3) {
        x <<= 1;
        uint256 z = 3 * x * (x + 1) + 1;
        if (n / y >= z) {
          n -= y * z;
          x += 1;
        }
      }
      return x;
    }
  }

  /**
   * @dev Compute the smallest integer larger than or equal to the cubic root of `n`
   */
  function ceilCbrt(uint256 n) internal pure returns (uint256) {
    unchecked {
      uint256 x = floorCbrt(n);
      return x ** 3 == n ? x : x + 1;
    }
  }

  /**
   * @dev Compute the nearest integer to the quotient of `n` and `d` (or `n / d`)
   */
  function roundDiv(uint256 n, uint256 d) internal pure returns (uint256) {
    unchecked {
      return n / d + (n % d) / (d - d / 2);
    }
  }

  /**
   * @dev Compute the largest integer smaller than or equal to `x * y / z`
   */
  function mulDivF(
    uint256 x,
    uint256 y,
    uint256 z
  ) internal pure returns (uint256) {
    unchecked {
      (uint256 xyh, uint256 xyl) = mul512(x, y);
      if (xyh == 0) {
        // `x * y < 2 ^ 256`
        return xyl / z;
      }
      if (xyh < z) {
        // `x * y / z < 2 ^ 256`
        uint256 m = mulMod(x, y, z); // `m = x * y % z`
        (uint256 nh, uint256 nl) = sub512(xyh, xyl, m); // `n = x * y - m` hence `n / z = floor(x * y / z)`
        if (nh == 0) {
          // `n < 2 ^ 256`
          return nl / z;
        }
        uint256 p = unsafeSub(0, z) & z; // `p` is the largest power of 2 which `z` is divisible by
        uint256 q = div512(nh, nl, p); // `n` is divisible by `p` because `n` is divisible by `z` and `z` is divisible by `p`
        uint256 r = inv256(z / p); // `z / p = 1 mod 2` hence `inverse(z / p) = 1 mod 2 ^ 256`
        return unsafeMul(q, r); // `q * r = (n / p) * inverse(z / p) = n / z`
      }
      revert(); // `x * y / z >= 2 ^ 256`
    }
  }

  /**
   * @dev Compute the smallest integer larger than or equal to `x * y / z`
   */
  function mulDivC(
    uint256 x,
    uint256 y,
    uint256 z
  ) internal pure returns (uint256) {
    unchecked {
      uint256 w = mulDivF(x, y, z);
      if (mulMod(x, y, z) > 0) return safeAdd(w, 1);
      return w;
    }
  }

  /**
   * @dev Compute the value of `x * y`
   */
  function mul512(
    uint256 x,
    uint256 y
  ) private pure returns (uint256, uint256) {
    unchecked {
      uint256 p = mulModMax(x, y);
      uint256 q = unsafeMul(x, y);
      if (p >= q) return (p - q, q);
      return (unsafeSub(p, q) - 1, q);
    }
  }

  /**
   * @dev Compute the value of `2 ^ 256 * xh + xl - y`, where `2 ^ 256 * xh + xl >= y`
   */
  function sub512(
    uint256 xh,
    uint256 xl,
    uint256 y
  ) private pure returns (uint256, uint256) {
    unchecked {
      if (xl >= y) return (xh, xl - y);
      return (xh - 1, unsafeSub(xl, y));
    }
  }

  /**
   * @dev Compute the value of `(2 ^ 256 * xh + xl) / pow2n`, where `xl` is divisible by `pow2n`
   */
  function div512(
    uint256 xh,
    uint256 xl,
    uint256 pow2n
  ) private pure returns (uint256) {
    unchecked {
      uint256 pow2nInv = unsafeAdd(unsafeSub(0, pow2n) / pow2n, 1); // `1 << (256 - n)`
      return unsafeMul(xh, pow2nInv) | (xl / pow2n); // `(xh << (256 - n)) | (xl >> n)`
    }
  }

  /**
   * @dev Compute the inverse of `d` modulo `2 ^ 256`, where `d` is congruent to `1` modulo `2`
   */
  function inv256(uint256 d) private pure returns (uint256) {
    unchecked {
      // approximate the root of `f(x) = 1 / x - d` using the newton–raphson convergence method
      uint256 x = 1;
      for (uint256 i = 0; i < 8; ++i)
        x = unsafeMul(x, unsafeSub(2, unsafeMul(x, d))); // `x = x * (2 - x * d) mod 2 ^ 256`
      return x;
    }
  }
}

library FractionMath {
  uint256 internal constant MAX_EXP_BIT_LEN = 40;
  uint256 internal constant MAX_EXP = 2 ** MAX_EXP_BIT_LEN - 1;
  uint256 internal constant MAX_UINT128 = type(uint128).max;

  /**
   * @dev Compute the power of a given ratio
   *
   * @param n The ratio numerator
   * @param d The ratio denominator
   * @param exp The exponentiation value
   * @param fast Opt for performance over accuracy
   *
   * @return The powered ratio numerator
   * @return The powered ratio denominator
   */
  function poweredRatio(
    uint256 n,
    uint256 d,
    uint256 exp,
    bool fast
  ) internal pure returns (uint256, uint256) {
    unchecked {
      require(exp <= MAX_EXP, "exp too large");

      function(uint256, uint256, uint256, uint256)
        pure
        returns (uint256, uint256) safeRatio = fast
          ? mulRatio128
          : productRatio;

      uint256[MAX_EXP_BIT_LEN] memory ns;
      uint256[MAX_EXP_BIT_LEN] memory ds;

      (ns[0], ds[0]) = safeRatio(n, 1, d, 1);
      for (uint256 i = 0; (exp >> i) > 1; ++i) {
        (ns[i + 1], ds[i + 1]) = safeRatio(ns[i], ns[i], ds[i], ds[i]);
      }

      n = 1;
      d = 1;

      for (uint256 i = 0; (exp >> i) > 0; ++i) {
        if (((exp >> i) & 1) > 0) {
          (n, d) = safeRatio(n, ns[i], d, ds[i]);
        }
      }

      return (n, d);
    }
  }

  /**
   * @dev Compute the product of two given ratios
   *
   * @param xn The 1st ratio numerator
   * @param yn The 2nd ratio numerator
   * @param xd The 1st ratio denominator
   * @param yd The 2nd ratio denominator
   *
   * @return The product ratio numerator
   * @return The product ratio denominator
   */
  function productRatio(
    uint256 xn,
    uint256 yn,
    uint256 xd,
    uint256 yd
  ) internal pure returns (uint256, uint256) {
    unchecked {
      uint256 n = IntegralMath.mulDivC(xn, yn, MAX_VAL);
      uint256 d = IntegralMath.mulDivC(xd, yd, MAX_VAL);
      uint256 z = n > d ? n : d;
      if (z > 1) {
        return (
          IntegralMath.mulDivC(xn, yn, z),
          IntegralMath.mulDivC(xd, yd, z)
        );
      }
      return (xn * yn, xd * yd);
    }
  }

  /**
   * @dev Reduce the components of a given ratio
   *
   * @param n The ratio numerator
   * @param d The ratio denominator
   * @param max The maximum desired value
   *
   * @return The reduced ratio numerator
   * @return The reduced ratio denominator
   */
  function reducedRatio(
    uint256 n,
    uint256 d,
    uint256 max
  ) internal pure returns (uint256, uint256) {
    unchecked {
      uint256 scale = ((n > d ? n : d) - 1) / max + 1;
      return (n / scale, d / scale);
    }
  }

  /**
   * @dev Compute a normalized ratio as `scale * n / (n + d)` and `scale * d / (n + d)`
   *
   * @param n The ratio numerator
   * @param d The ratio denominator
   * @param scale The desired scale
   *
   * @return The normalized ratio numerator
   * @return The normalized ratio denominator
   */
  function normalizedRatio(
    uint256 n,
    uint256 d,
    uint256 scale
  ) internal pure returns (uint256, uint256) {
    unchecked {
      if (n <= d) {
        return estimatedRatio(n, d, scale);
      }
      (d, n) = estimatedRatio(d, n, scale);
      return (n, d);
    }
  }

  /**
   * @dev Compute an estimated ratio as `scale * n / (n + d)` and `scale * d / (n + d)`, assuming that `n <= d`
   *
   * @param n The ratio numerator
   * @param d The ratio denominator
   * @param scale The desired scale
   *
   * @return The estimated ratio numerator
   * @return The estimated ratio denominator
   */
  function estimatedRatio(
    uint256 n,
    uint256 d,
    uint256 scale
  ) private pure returns (uint256, uint256) {
    unchecked {
      uint256 x = MAX_VAL / scale;
      if (n > x) {
        // `n * scale` will overflow
        uint256 y = (n - 1) / x + 1;
        n /= y;
        d /= y;
        // `n * scale` will not overflow
      }

      if (n < d) {
        uint256 p = n * scale;
        uint256 q = unsafeAdd(n, d); // `n + d` can overflow
        if (q >= n) {
          // `n + d` did not overflow
          uint256 r = IntegralMath.roundDiv(p, q);
          return (r, scale - r); // `r = n * scale / (n + d) < scale`
        }
        if (p < d - (d - n) / 2) {
          return (0, scale); // `n * scale < (n + d) / 2 < MAX_VAL < n + d`
        }
        return (1, scale - 1); // `(n + d) / 2 < n * scale < MAX_VAL < n + d`
      }
      return (scale / 2, scale - scale / 2); // reflect the fact that initially `n <= d`
    }
  }

  /**
   * @dev Compute the product of two ratios and reduce the components of the result to 128 bits,
   * under the implicit assumption that the components of the product are not larger than 256 bits
   *
   * @param xn The 1st ratio numerator
   * @param yn The 2nd ratio numerator
   * @param xd The 1st ratio denominator
   * @param yd The 2nd ratio denominator
   *
   * @return The product ratio numerator
   * @return The product ratio denominator
   */
  function mulRatio128(
    uint256 xn,
    uint256 yn,
    uint256 xd,
    uint256 yd
  ) private pure returns (uint256, uint256) {
    unchecked {
      return reducedRatio(xn * yn, xd * yd, MAX_UINT128);
    }
  }
}
