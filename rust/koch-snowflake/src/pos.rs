
pub type Pos = (f32, f32);

pub const FRAC_TAU_6: f32 = std::f32::consts::FRAC_PI_3;
pub const FRAC_TAU_3: f32 = 2f32 * FRAC_TAU_6;

pub fn sqr(a: f32) -> f32 { a * a }

pub fn pos_plus(a: Pos, b: Pos) -> Pos { (a.0 + b.0, a.1 + b.1) }

pub fn pos_minus(a: Pos, b: Pos) -> Pos { (a.0 - b.0, a.1 - b.1) }

pub fn pos_delta(a: Pos, b: Pos) -> Pos { (b.0 - a.0, b.1 - a.1) }

pub fn pos_div(a: Pos, s: f32) -> Pos { (a.0 / s, a.1 / s) }

pub fn pos_dist1(a: Pos) -> f32 { f32::sqrt(sqr(a.0) + sqr(a.1)) }

pub fn pos_rotate(a: Pos, r: f32) -> Pos {
    ((f32::cos(r) * a.0) + (f32::sin(r) * a.1),
     (- f32::sin(r) * a.0) + (f32::cos(r) * a.1))
}

pub fn pos_round_i32(a: Pos) -> (i32, i32) {
    (a.0.round() as i32, a.1.round() as i32)
}
