import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HalamanMataKuliah extends StatelessWidget {
  const HalamanMataKuliah({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6, // 6 tabs untuk Senin sampai Sabtu
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Halaman Mata Kuliah',
            style: GoogleFonts.quicksand(
              color: Colors.black,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          backgroundColor: Colors.lightBlue,
          bottom: const TabBar(
            tabs: [
              Tab(
                text: 'Senin',
                icon: Icon(Icons.calendar_today), // Optional: Tambahkan ikon jika perlu
              ),
              Tab(
                text: 'Selasa',
                icon: Icon(Icons.calendar_today),
              ),
              Tab(
                text: 'Rabu',
                icon: Icon(Icons.calendar_today),
              ),
              Tab(
                text: 'Kamis',
                icon: Icon(Icons.calendar_today),
              ),
              Tab(
                text: 'Jumat',
                icon: Icon(Icons.calendar_today),
              ),
              Tab(
                text: 'Sabtu',
                icon: Icon(Icons.calendar_today),
              ),
            ],
            labelColor: Colors.black, // Mengubah warna teks tab
            unselectedLabelColor: Colors.black12, // Mengubah warna teks tab yang tidak dipilih
            labelStyle: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildJadwalForDay('Senin'),
            _buildJadwalForDay('Selasa'),
            _buildJadwalForDay('Rabu'),
            _buildJadwalForDay('Kamis'),
            _buildJadwalForDay('Jumat'),
            _buildJadwalForDay('Sabtu'),
          ],
        ),
      ),
    );
  }

  Widget _buildJadwalForDay(String hari) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('jadwal').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Belum ada jadwal.'));
        }

        final data = snapshot.data!.docs;

        // Filter data berdasarkan hari
        final filteredData = data.where((doc) {
          final item = doc.data() as Map<String, dynamic>;
          final day = item['hari'] ?? '';
          return day == hari;
        }).toList();

        if (filteredData.isEmpty) {
          return Center(child: Text('Tidak ada jadwal untuk $hari.'));
        }

        return ListView(
          children: filteredData.map((doc) {
            final item = doc.data() as Map<String, dynamic>;
            return ListTile(
              title: Text(item['mataKuliah'] ?? 'Mata Kuliah Tidak Diketahui'),
              subtitle: Text('${item['waktuMulai']} - ${item['waktuSelesai']}'),
            );
          }).toList(),
        );
      },
    );
  }
}
