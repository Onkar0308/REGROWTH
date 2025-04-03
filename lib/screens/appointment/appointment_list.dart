// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:regrowth_mobile/screens/appointment/appointment_details.dart';
import '../../model/appointment_model.dart';
import '../../provider/refresh_provider.dart';
import '../../services/appointment_service.dart';
import '../../utils/contants.dart';
import 'package:provider/provider.dart';

class AppointmentList extends StatefulWidget {
  const AppointmentList({super.key});

  @override
  State<AppointmentList> createState() => _AppointmentListState();
}

class _AppointmentListState extends State<AppointmentList>
    with WidgetsBindingObserver {
  late Future<List<Appointment>> _appointments;
  late DateTime _selectedDate;
  late int _selectedYear, _selectedMonth;
  Map<DateTime, List<Appointment>> _appointmentsByDate = {};

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedYear = _selectedDate.year;
    _selectedMonth = _selectedDate.month;
    _appointments = getAppointmentList();
    _loadAppointments();
    WidgetsBinding.instance.addObserver(this);
  }

  void _loadAppointments() async {
    List<Appointment> appointments = await _appointments;
    setState(() {
      _appointmentsByDate = {};
      for (var appointment in appointments) {
        DateTime date =
            DateFormat("dd-MM-yyyy").parse(appointment.appointmentDate);
        _appointmentsByDate.putIfAbsent(date, () => []).add(appointment);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _appointments = getAppointmentList();
      _loadAppointments();
    }
  }

  void _showAppointmentsPopup(BuildContext context, DateTime date) {
    List<Appointment> appointments = _appointmentsByDate[date] ?? [];

    // Sorting appointments by startTime
    appointments.sort((a, b) => a.startTime.compareTo(b.startTime));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Appointments on ${date.day}-${date.month}-${date.year}",
            style: const TextStyle(fontFamily: 'Lexend'),
          ),
          content: appointments.isNotEmpty
              ? SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: appointments
                        .map(
                          (appointment) => ListTile(
                              title: Text(
                                "Name: ${appointment.firstName} ${appointment.lastName}",
                                style: const TextStyle(fontFamily: 'Lexend'),
                              ),
                              subtitle: Text("Time: ${appointment.startTime}"),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AppointmentDetails(
                                        appointment: appointment),
                                  ),
                                );
                              }),
                        )
                        .toList(),
                  ),
                )
              : const Text("No appointments on this day"),
          actions: [
            TextButton(
              child: const Text("Okay"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Container _buildDayContainer(String dayName) {
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
      alignment: Alignment.center,
      child: Text(
        dayName,
        style: const TextStyle(
          fontFamily: 'Lexend',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Appointments',
          style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.w400),
        ),
        backgroundColor: AppColors.primary,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              icon: const Icon(
                Icons.library_add_outlined,
                color: Colors.black,
                size: 28,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/create_appointment');
              },
            ),
          ),
        ],
      ),
      body: Consumer<RefreshStateNotifier>(
        builder: (context, refreshState, child) {
          if (refreshState.shouldRefresh) {
            _appointments = getAppointmentList();
            _loadAppointments();
            refreshState.resetRefresh();
          }

          return GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! > 0) {
                // Swiped from left to right (Previous Month)
                setState(() {
                  _selectedMonth--;
                  if (_selectedMonth < 1) {
                    _selectedMonth = 12;
                    _selectedYear--;
                  }
                  _loadAppointments(); // Fetch new month's data
                });
              } else if (details.primaryVelocity! < 0) {
                // Swiped from right to left (Next Month)
                setState(() {
                  _selectedMonth++;
                  if (_selectedMonth > 12) {
                    _selectedMonth = 1;
                    _selectedYear++;
                  }
                  _loadAppointments(); // Fetch new month's data
                });
              }
            },
            child: Column(
              children: [
                // Month & Year Header
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_left, size: 30),
                        onPressed: () {
                          setState(() {
                            _selectedMonth--;
                            if (_selectedMonth < 1) {
                              _selectedMonth = 12;
                              _selectedYear--;
                            }
                            _loadAppointments();
                          });
                        },
                      ),
                      Text(
                        "${_getMonthName(_selectedMonth)} $_selectedYear",
                        style: const TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_right, size: 30),
                        onPressed: () {
                          setState(() {
                            _selectedMonth++;
                            if (_selectedMonth > 12) {
                              _selectedMonth = 1;
                              _selectedYear++;
                            }
                            _loadAppointments();
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // Days of the week
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3), // shadow color
                          spreadRadius: 1, // how much spread you want
                          blurRadius: 2, // how much blur you want
                          offset: const Offset(
                              0, 3), // offset changes the shadow position
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildDayContainer('Mon'),
                              _buildDayContainer('Tue'),
                              _buildDayContainer('Wed'),
                              _buildDayContainer('Thu'),
                              _buildDayContainer('Fri'),
                              _buildDayContainer('Sat'),
                              _buildDayContainer('Sun'),
                            ],
                          ),
                        ),

                        // Calendar Grid
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              childAspectRatio: 1.1,
                            ),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount:
                                DateTime(_selectedYear, _selectedMonth + 1, 0)
                                        .day +
                                    (DateTime(_selectedYear, _selectedMonth, 1)
                                            .weekday -
                                        1),
                            itemBuilder: (context, index) {
                              DateTime currentDate = DateTime(
                                _selectedYear,
                                _selectedMonth,
                                index +
                                    1 -
                                    DateTime(_selectedYear, _selectedMonth, 1)
                                        .weekday +
                                    1,
                              );

                              if (index <
                                  DateTime(_selectedYear, _selectedMonth, 1)
                                          .weekday -
                                      1) {
                                return Container(); // Empty cell for padding
                              }

                              bool hasAppointments =
                                  _appointmentsByDate.containsKey(currentDate);

                              return GestureDetector(
                                onTap: () => _showAppointmentsPopup(
                                    context, currentDate),
                                child: Container(
                                  margin: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: hasAppointments
                                        ? Colors.blue.withOpacity(0.2)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: hasAppointments
                                          ? Colors.blue
                                          : Colors.grey,
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${currentDate.day}',
                                        style: const TextStyle(
                                          fontFamily: 'Lexend',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                        ),
                                      ),
                                      if (hasAppointments) ...[
                                        const SizedBox(height: 5),
                                        Container(
                                          width: 32,
                                          height: 3,
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
