#ifndef POLYNOMINAL_H
#define POLYNOMINAL_H

#include <QObject>

namespace pdf_viewer {

/*!
 * \class Polynomial
 * \brief Controllable nth-order polynomial used for animation.
 *
 * The polynomial is constructed from five parameters: n, x0, y0, x1 and y1.
 * It guarantees to fulfill following requirements:
 * 1. f(x0) = y0
 * 2. f'(x0) = 0
 * 3. f(x1) = y1
 * 4. f'(x1) != 0 if y0 != y1
 *
 * In short, the function is flat at (x0|y0) at crosses (x1|y1).
 * If y1 is smaller than y0, the curve open at the bottom.
 *
 * n relates to the polynomial order. n of 2 is a quadratic curve,
 * n of 3 a cubic one and so on. n of 1 is a linear curve with a
 * constant gradient. Unlike the anchoring parameters xy0 and xy1,
 * n is fixed and invariant.
 */
class Polynomial
{

public:

    /*!
     * \brief Construct a new polynomial.
     * \param n Order of curve.
     * \attention n must be greater than 0.
     */
    Polynomial(unsigned const n);

    /*!
     * \brief Re-anchors the animation curve to different points.
     * \param x0 Origin of curve.
     * \param y0 Origin of curve.
     * \param x1 Control point.
     * \param y1 Control point.
     * \attention x1 must differ from x0!
     * \note If y1 equals y0, the curve is a horizontal line at y = y0.
     */
    void set(qreal const x0, qreal const y0, qreal const x1, qreal const y1);

    /*!
     * \brief Evaluates the polynomial at x.
     * \param x X value to evaluate.
     * \return Y value.
     */
    qreal operator()(qreal const x) const;

private:

    unsigned const mN;
    qreal mA, mX0, mY0;

};

} // namespace pdf_viewer

#endif // POLYNOMINAL_H
