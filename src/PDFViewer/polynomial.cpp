#include "polynomial.h"

#include <qmath.h>

namespace pdf_viewer {

Polynomial::Polynomial(const unsigned n)
    : mN(n)
{
    Q_ASSERT(n > 0);
}

void Polynomial::set(qreal const x0, qreal const y0, qreal const x1, qreal const y1)
{
    mX0 = x0;
    mY0 = y0;
    mA = (y1 - y0) / qPow(x1 - x0, mN);
}

qreal Polynomial::operator()(qreal const x) const
{
    return mA * qPow(x - mX0, mN) + mY0;
}

} // namespace pdf_viewer
