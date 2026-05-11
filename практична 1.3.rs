// rust-practice/03_variables/variables.rs

fn main() {
    // 1. Immutable variable
    let x = 5;
    println!("The value of x is: {}", x);

    // 2. Mutable variable
    let mut y = 10;
    println!("The value of y is: {}", y);
    y = 15;  // OK, бо mutable
    println!("Now y is: {}", y);

    // 3. Shadowing (затінення)
    let z = 42;
    println!("z = {}", z);

    let z = "hello";  // новий z іншого типу
    println!("z = {}", z);

    // 4. Константа (must be uppercase + type)
    const MAX_POINTS: u32 = 100_000;
    println!("Max points: {}", MAX_POINTS);
}
