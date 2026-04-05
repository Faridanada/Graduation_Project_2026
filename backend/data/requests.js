let requestsList = [
    {
        id: 'req_1',
        doctorId: 'doctor1', // Matches the mock token doctor ID
        patientId: 'patient1', // The user who made the request
        name: 'John Doe',
        type: 'Appointment Request',
        message: 'Requesting appointment for next Tuesday at 2 PM',
        timestamp: '10 mins ago',
        status: 'pending',
    },
    {
        id: 'req_2',
        doctorId: 'doctor1',
        patientId: 'patient2',
        name: 'Alice Smith',
        type: 'Exercise Question',
        message: 'Is it normal to feel slight discomfort during the knee exercises?',
        timestamp: '2 hours ago',
        status: 'pending',
    },
    {
        id: 'req_3',
        doctorId: 'doctor1',
        patientId: 'patient3',
        name: 'Mark Lee',
        type: 'Prescription Refill',
        message: 'Need prescription refill for pain medication',
        timestamp: '1 day ago',
        status: 'completed',
    }
];

module.exports = {
    requestsList,
};
