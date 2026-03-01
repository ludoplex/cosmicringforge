// OpenModelica Example: Simple Pendulum
// Ring 2 tool - generates simulation C code
//
// Build: omc pendulum.mo
// Output: Pendulum.c, Pendulum_functions.c, Pendulum.makefile

model Pendulum "Simple pendulum with damping"
    // Parameters (constant during simulation)
    parameter Real L = 1.0 "Pendulum length [m]";
    parameter Real g = 9.81 "Gravitational acceleration [m/s^2]";
    parameter Real b = 0.1 "Damping coefficient [N.m.s/rad]";
    parameter Real m = 1.0 "Mass [kg]";

    // State variables
    Real theta(start = 0.5, fixed = true) "Angle from vertical [rad]";
    Real omega(start = 0.0, fixed = true) "Angular velocity [rad/s]";

    // Derived quantities
    Real x "Horizontal position [m]";
    Real y "Vertical position [m]";
    Real E_kinetic "Kinetic energy [J]";
    Real E_potential "Potential energy [J]";
    Real E_total "Total energy [J]";

equation
    // Equations of motion (differential-algebraic equations)
    der(theta) = omega;
    m * L^2 * der(omega) = -m * g * L * sin(theta) - b * omega;

    // Position (for visualization)
    x = L * sin(theta);
    y = -L * cos(theta);

    // Energy calculations
    E_kinetic = 0.5 * m * L^2 * omega^2;
    E_potential = m * g * L * (1 - cos(theta));
    E_total = E_kinetic + E_potential;

    annotation(
        experiment(StartTime = 0, StopTime = 10, Tolerance = 1e-6),
        Documentation(info = "<html>
            <p>Simple pendulum model with damping.</p>
            <p>The pendulum swings under gravity and gradually loses energy due to damping.</p>
        </html>")
    );
end Pendulum;

// More complex: Double Pendulum (chaotic system)
model DoublePendulum "Double pendulum - chaotic dynamics"
    parameter Real L1 = 1.0 "Length of first arm [m]";
    parameter Real L2 = 1.0 "Length of second arm [m]";
    parameter Real m1 = 1.0 "Mass of first bob [kg]";
    parameter Real m2 = 1.0 "Mass of second bob [kg]";
    parameter Real g = 9.81 "Gravity [m/s^2]";

    Real theta1(start = 3.14159/2, fixed = true) "First angle [rad]";
    Real theta2(start = 3.14159/2, fixed = true) "Second angle [rad]";
    Real omega1(start = 0, fixed = true) "First angular velocity [rad/s]";
    Real omega2(start = 0, fixed = true) "Second angular velocity [rad/s]";

    // Positions for visualization
    Real x1, y1, x2, y2;

protected
    Real delta "Angle difference";
    Real den1, den2 "Denominators";

equation
    delta = theta2 - theta1;

    // Equations of motion (Lagrangian mechanics)
    den1 = (m1 + m2) * L1 - m2 * L1 * cos(delta)^2;
    den2 = (L2 / L1) * den1;

    der(theta1) = omega1;
    der(theta2) = omega2;

    der(omega1) = (m2 * L1 * omega1^2 * sin(delta) * cos(delta)
                 + m2 * g * sin(theta2) * cos(delta)
                 + m2 * L2 * omega2^2 * sin(delta)
                 - (m1 + m2) * g * sin(theta1)) / den1;

    der(omega2) = (-m2 * L2 * omega2^2 * sin(delta) * cos(delta)
                 + (m1 + m2) * g * sin(theta1) * cos(delta)
                 - (m1 + m2) * L1 * omega1^2 * sin(delta)
                 - (m1 + m2) * g * sin(theta2)) / den2;

    // Positions
    x1 = L1 * sin(theta1);
    y1 = -L1 * cos(theta1);
    x2 = x1 + L2 * sin(theta2);
    y2 = y1 - L2 * cos(theta2);

    annotation(
        experiment(StartTime = 0, StopTime = 30, Tolerance = 1e-8)
    );
end DoublePendulum;
