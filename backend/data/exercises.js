const exercisesData = [
    {
        id: "ex1",
        patientId: "patient_1",
        doctorId: "doctor_1",
        title: "Knee Flexion \u2013 Active Mode",
        estimatedTimeMin: 15,
        repsCompleted: 0,
        repsTotal: 20,
        status: "pending", // pending, completed
        instructions: "Sit on a chair and slowly bend your knee as far back as comfortable.",
        dateAssigned: new Date().toISOString().split('T')[0] // today's date
    },
    {
        id: "ex2",
        patientId: "patient_1",
        doctorId: "doctor_1",
        title: "Straight Leg Raise",
        estimatedTimeMin: 10,
        repsCompleted: 5,
        repsTotal: 15,
        status: "in-progress",
        instructions: "Lie on your back and raise your straight leg up to 45 degrees.",
        dateAssigned: new Date().toISOString().split('T')[0]
    }
];

module.exports = exercisesData;
