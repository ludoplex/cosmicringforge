# math.sig — Math function signatures
# Example signature spec for siggen

module math {
    fn add(a: i32, b: i32) -> i32
    fn multiply(a: f64, b: f64) -> f64 [pure]
    fn vector_dot(v1: *f32, v2: *f32, len: usize) -> f32
}
