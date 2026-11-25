# Egger slope bias under the known-answer test's design (theta = 2, exposure SE 0.003 SD), corrected units
set.seed(7)
one <- function(sx) { n <- 320; b <- sample(c(-1,1), n, TRUE) * runif(n, .03, .08)
  bx <- (b + rnorm(n, 0, sx)) * 4.8; by <- 2 * b * 4.8 + rnorm(n, 0, .03)
  s <- sign(bx); x <- bx * s; y <- by * s
  coef(lm(y ~ x, weights = rep(1 / .03^2, n)))[2] }
for (sx in c(.003, .0005)) { r <- replicate(1000, one(sx))
  cat(sprintf("sx=%.4f  mean Egger slope %.3f (sd %.3f); I2GX=%.4f\n", sx, mean(r), sd(r), 1 - sx^2 / (.05^2 / 12))) }
