extern crate image;
extern crate imageproc;
mod pos;
mod draw;

use pos::*;
use draw::*;

const DEFAULT_LINE_CUTOFF: f32 = 4f32;

fn main() {
    let mut img = RgbaImage::from_pixel(728, 728, WHITE);
    koch_curve(&mut img, (5f32, 5f32), (723f32, 723f32), BLACK);
    img.save("koch_curve.png").unwrap();
    let mut img_cave = RgbaImage::from_pixel(728, 728, WHITE);
    koch_curve_cave(&mut img_cave, (5f32, 5f32), (723f32, 723f32), BLACK);
    img_cave.save("koch_curve_cave.png").unwrap();
    let mut img_cave2 = RgbaImage::from_pixel(728, 728, WHITE);
    koch_curve_cave2(&mut img_cave2, (5f32, 5f32), (723f32, 723f32), BLACK);
    koch_curve_cave2(&mut img_cave2, (723f32, 723f32), (5f32, 5f32), BLACK);
    img_cave2.save("koch_curve_cave2.png").unwrap();
    let mut img_reflected = RgbaImage::from_pixel(728, 728, WHITE);
    koch_curve_reflected(&mut img_reflected, (5f32, 5f32), (723f32, 723f32), BLACK);
    img_reflected.save("koch_curve_reflected.png").unwrap();
    let mut img_reflected2 = RgbaImage::from_pixel(728, 728, WHITE);
    koch_curve_reflected2(&mut img_reflected2, (5f32, 5f32), (723f32, 723f32), BLACK);
    img_reflected2.save("koch_curve_reflected2.png").unwrap();
    let mut img_snowflake = RgbaImage::from_pixel(728, 728, WHITE);
    koch_snowflake(&mut img_snowflake, (364f32, 364f32), 359f32, BLACK);
    img_snowflake.save("koch_snowflake.png").unwrap();
    let mut img_snowflake_reflections = RgbaImage::from_pixel(728, 728, WHITE);
    koch_snowflake_reflections(&mut img_snowflake_reflections, (364f32, 364f32), 359f32, BLACK);
    img_snowflake_reflections.save("koch_snowflake_reflections.png").unwrap();
    let mut img_snowflake_cave = RgbaImage::from_pixel(728, 728, WHITE);
    koch_snowflake_cave(&mut img_snowflake_cave, (364f32, 364f32), 359f32, BLACK);
    img_snowflake_cave.save("koch_snowflake_cave.png").unwrap();
    let mut img_snowflake_reflections2 = RgbaImage::from_pixel(728, 728, WHITE);
    koch_snowflake_reflections2(&mut img_snowflake_reflections2, (364f32, 364f32), 359f32, BLACK);
    img_snowflake_reflections2.save("koch_snowflake_reflections2.png").unwrap();
    let mut img_snowflake_cave2 = RgbaImage::from_pixel(728, 728, WHITE);
    koch_snowflake_cave2(&mut img_snowflake_cave2, (364f32, 364f32), 359f32, BLACK);
    img_snowflake_cave2.save("koch_snowflake_cave2.png").unwrap();
    let mut img_layered_rc = LayeredImage::from_pixels(728, 728, vec![TRANSPARENT, TRANSPARENT, WHITE]);
    img_layered_rc.on_layer(1, |img| koch_snowflake_reflections2(img, (364f32, 364f32), 359f32, BLUE));
    img_layered_rc.on_layer(0, |img| koch_snowflake_cave(img, (364f32, 364f32), 359f32, GOLD));
    img_layered_rc.save("koch_snowflake_layered_rc.png").unwrap();
    let mut img_reflected_layered2 = LayeredImage::from_pixels(728, 728, vec![TRANSPARENT, TRANSPARENT, WHITE]);
    koch_snowflake_reflections_layered(&mut img_reflected_layered2, (364f32, 364f32), 300f32, vec![RED, GREEN]);
    img_reflected_layered2.save("koch_snowflake_reflected_layered2.png").unwrap();
    let mut img_reflected_layered3 = LayeredImage::from_pixels(728, 728, vec![TRANSPARENT, TRANSPARENT, TRANSPARENT, WHITE]);
    koch_snowflake_reflections_layered(&mut img_reflected_layered3, (364f32, 364f32), 300f32, vec![RED, BLUE, GREEN]);
    img_reflected_layered3.save("koch_snowflake_reflected_layered3.png").unwrap();
}

fn koch_snowflake(img: &mut RgbaImage, center: Pos, radius: f32, color: Color) {
    let ct = (0f32, -radius);
    let cl = pos_rotate(ct, FRAC_TAU_3);
    let cr = pos_rotate(ct, -FRAC_TAU_3);
    let t = pos_plus(center, ct);
    let bl = pos_plus(center, cl);
    let br = pos_plus(center, cr);
    koch_curve(img, t, br, color);
    koch_curve(img, br, bl, color);
    koch_curve(img, bl, t, color);
}

fn koch_snowflake_reflections(img: &mut RgbaImage, center: Pos, radius: f32, color: Color) {
    let ct = (0f32, -radius);
    let cl = pos_rotate(ct, FRAC_TAU_3);
    let cr = pos_rotate(ct, -FRAC_TAU_3);
    let t = pos_plus(center, ct);
    let bl = pos_plus(center, cl);
    let br = pos_plus(center, cr);
    let b = pos_minus(center, ct);
    let tl = pos_minus(center, cr);
    let tr = pos_minus(center, cl);
    draw_line_segment_mut(img, b, tl, color);
    draw_line_segment_mut(img, tl, tr, color);
    draw_line_segment_mut(img, tr, b, color);
    koch_curve_reflected(img, t, br, color);
    koch_curve_reflected(img, br, bl, color);
    koch_curve_reflected(img, bl, t, color);
}

fn koch_snowflake_cave(img: &mut RgbaImage, center: Pos, radius: f32, color: Color) {
    let ct = (0f32, -radius);
    let cl = pos_rotate(ct, FRAC_TAU_3);
    let cr = pos_rotate(ct, -FRAC_TAU_3);
    let t = pos_plus(center, ct);
    let bl = pos_plus(center, cl);
    let br = pos_plus(center, cr);
    koch_curve_cave(img, t, br, color);
    koch_curve_cave(img, br, bl, color);
    koch_curve_cave(img, bl, t, color);
}

fn koch_snowflake_reflections2(img: &mut RgbaImage, center: Pos, radius: f32, color: Color) {
    let ct = (0f32, -radius);
    let cl = pos_rotate(ct, FRAC_TAU_3);
    let cr = pos_rotate(ct, -FRAC_TAU_3);
    let t = pos_plus(center, ct);
    let bl = pos_plus(center, cl);
    let br = pos_plus(center, cr);
    koch_curve_reflected2(img, t, br, color);
    koch_curve_reflected2(img, br, bl, color);
    koch_curve_reflected2(img, bl, t, color);
}

fn koch_snowflake_reflections_layered(img: &mut LayeredImage, center: Pos, radius: f32, colors: Vec<Color>) {
    let ct = (0f32, -radius);
    let cl = pos_rotate(ct, FRAC_TAU_3);
    let cr = pos_rotate(ct, -FRAC_TAU_3);
    let t = pos_plus(center, ct);
    let bl = pos_plus(center, cl);
    let br = pos_plus(center, cr);
    koch_curve_reflected_layered(img, t, br, 0, &colors);
    koch_curve_reflected_layered(img, br, bl, 0, &colors);
    koch_curve_reflected_layered(img, bl, t, 0, &colors);
}

fn koch_snowflake_cave2(img: &mut RgbaImage, center: Pos, radius: f32, color: Color) {
    let ct = (0f32, -radius);
    let cl = pos_rotate(ct, FRAC_TAU_3);
    let cr = pos_rotate(ct, -FRAC_TAU_3);
    let t = pos_plus(center, ct);
    let bl = pos_plus(center, cl);
    let br = pos_plus(center, cr);
    koch_curve_cave2(img, t, br, color);
    koch_curve_cave2(img, br, bl, color);
    koch_curve_cave2(img, bl, t, color);
    koch_curve_cave2(img, br, t, color);
    koch_curve_cave2(img, bl, br, color);
    koch_curve_cave2(img, t, bl, color);
}

fn koch_curve(img: &mut RgbaImage, a: Pos, b: Pos, c: Color) {
    let ab = pos_delta(a, b);
    if pos_dist1(ab) <= DEFAULT_LINE_CUTOFF {
        draw_line_segment_mut(img, a, b, c)
    } else {
        let ab3 = pos_div(ab, 3f32);
        let l = pos_plus(a, ab3);
        let t = pos_plus(l, pos_rotate(ab3, FRAC_TAU_6));
        let r = pos_plus(l, ab3);
        koch_curve(img, a, l, c);
        koch_curve(img, l, t, c);
        koch_curve(img, t, r, c);
        koch_curve(img, r, b, c);
    }
}

fn koch_curve_cave(img: &mut RgbaImage, a: Pos, b: Pos, c: Color) {
    let ab = pos_delta(a, b);
    if pos_dist1(ab) <= DEFAULT_LINE_CUTOFF {
        draw_line_segment_mut(img, a, b, c)
    } else {
        let ab3 = pos_div(ab, 3f32);
        let l = pos_plus(a, ab3);
        let t = pos_plus(l, pos_rotate(ab3, FRAC_TAU_6));
        let r = pos_plus(l, ab3);
        koch_curve_cave(img, t, a, c);
        koch_curve_cave(img, b, t, c);
        koch_curve_cave(img, r, l, c);
    }
}

fn koch_curve_cave2(img: &mut RgbaImage, a: Pos, b: Pos, c: Color) {
    let ab = pos_delta(a, b);
    if pos_dist1(ab) <= DEFAULT_LINE_CUTOFF {
        draw_line_segment_mut(img, a, b, c)
    } else {
        let ab3 = pos_div(ab, 3f32);
        let l = pos_plus(a, ab3);
        let t = pos_plus(l, pos_rotate(ab3, FRAC_TAU_6));
        let r = pos_plus(l, ab3);
        koch_curve_cave2(img, t, a, c);
        koch_curve_cave2(img, b, t, c);
        koch_curve_cave2(img, l, r, c);
        koch_curve_cave2(img, r, l, c);
    }
}

fn koch_curve_reflected(img: &mut RgbaImage, a: Pos, b: Pos, c: Color) {
    let ab = pos_delta(a, b);
    if pos_dist1(ab) <= DEFAULT_LINE_CUTOFF {
        draw_line_segment_mut(img, a, b, c)
    } else {
        let ab3 = pos_div(ab, 3f32);
        let l = pos_plus(a, ab3);
        let t = pos_plus(l, pos_rotate(ab3, FRAC_TAU_6));
        let v = pos_plus(l, pos_rotate(ab3, -FRAC_TAU_6));
        let r = pos_plus(l, ab3);
        draw_line_segment_mut(img, a, b, c);
        koch_curve_reflected(img, a, l, c);
        koch_curve_reflected(img, l, t, c);
        koch_curve_reflected(img, l, v, c);
        koch_curve_reflected(img, t, r, c);
        koch_curve_reflected(img, v, r, c);
        koch_curve_reflected(img, r, b, c);
    }
}

fn koch_curve_reflected2(img: &mut RgbaImage, a: Pos, b: Pos, c: Color) {
    let ab = pos_delta(a, b);
    if pos_dist1(ab) <= DEFAULT_LINE_CUTOFF {
        draw_line_segment_mut(img, a, b, c)
    } else {
        let ab3 = pos_div(ab, 3f32);
        let l = pos_plus(a, ab3);
        let t = pos_plus(l, pos_rotate(ab3, FRAC_TAU_6));
        let v = pos_plus(l, pos_rotate(ab3, -FRAC_TAU_6));
        let r = pos_plus(l, ab3);
        koch_curve_reflected2(img, a, l, c);
        koch_curve_reflected2(img, l, t, c);
        koch_curve_reflected2(img, l, r, c);
        koch_curve_reflected2(img, l, v, c);
        koch_curve_reflected2(img, t, r, c);
        koch_curve_reflected2(img, v, r, c);
        koch_curve_reflected2(img, r, b, c);
    }
}

fn koch_curve_reflected_layered(img: &mut LayeredImage, a: Pos, b: Pos, n: usize, cs: &[Color]) {
    if cs.len() <= n { return; }
    let ab = pos_delta(a, b);
    if pos_dist1(ab) <= DEFAULT_LINE_CUTOFF {
        img.on_layer(n, |i| draw_line_segment_mut(i, a, b, cs[n]));
    } else {
        let ab3 = pos_div(ab, 3f32);
        let l = pos_plus(a, ab3);
        let t = pos_plus(l, pos_rotate(ab3, FRAC_TAU_6));
        let v = pos_plus(l, pos_rotate(ab3, -FRAC_TAU_6));
        let r = pos_plus(l, ab3);
        koch_curve_reflected_layered(img, a, t, n+1, cs);
        koch_curve_reflected_layered(img, a, v, n+1, cs);
        koch_curve_reflected_layered(img, t, b, n+1, cs);
        koch_curve_reflected_layered(img, v, b, n+1, cs);
        koch_curve_reflected_layered(img, a, l, n, cs);
        koch_curve_reflected_layered(img, l, t, n, cs);
        koch_curve_reflected_layered(img, l, v, n, cs);
        koch_curve_reflected_layered(img, t, r, n, cs);
        koch_curve_reflected_layered(img, v, r, n, cs);
        koch_curve_reflected_layered(img, r, b, n, cs);
    }
}
