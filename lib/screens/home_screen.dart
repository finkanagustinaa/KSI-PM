import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ksi_pm/core/providers/schedule_provider.dart';
// Asumsikan ScheduleCard adalah widget yang Anda buat di Job Desk 1
// import 'package:ksi_pm/widgets/schedule_card.dart'; 

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Memanggil scheduleProvider
    final scheduleAsyncValue = ref.watch(scheduleProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Jadwal Kuliah')),
      body: scheduleAsyncValue.when( //
        data: (scheduleList) { //
          if (scheduleList.isEmpty) {
            return const Center(child: Text('Tidak ada jadwal kelas.')); //
          }
          return ListView.builder(
            itemCount: scheduleList.length,
            itemBuilder: (context, index) {
              final course = scheduleList[index];
              // Asumsi: ScheduleCard adalah widget yang menampilkan jadwal
              return ListTile( 
                title: Text(course.namaMatkul),
                subtitle: Text('${course.kodeMK} | ${course.hari}, ${course.jamMulai} - ${course.jamSelesai}'),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()), //
        error: (e, st) => Center(child: Text('Error: ${e.toString()}')), //
      ),
    );
  }
}