const appointmentsData = [
    {
        id: "app1",
        patientId: "patient_1",
        doctorId: "doctor_1",
        patientName: "John Doe",
        doctorName: "Dr. Smith",
        time: "11:00",
        date: "2026-04-29",
        status: "upcoming", // upcoming, completed, cancelled
        type: "Follow-up",
        notes: "Check progress on knee extension."
    },
    {
        id: "app2",
        patientId: "patient_2",
        doctorId: "doctor_1",
        patientName: "Fred Nerk",
        doctorName: "Dr. Smith",
        time: "13:30",
        date: "2026-04-29",
        status: "upcoming",
        type: "Initial Consult",
        notes: ""
    },
    {
        id: "app3",
        patientId: "patient_3",
        doctorId: "doctor_1",
        patientName: "Alice Smith",
        doctorName: "Dr. Smith",
        time: "15:00",
        date: "2026-04-29",
        status: "upcoming",
        type: "Therapy Session",
        notes: "Shoulder mobility exercises."
    }
];

module.exports = appointmentsData;
