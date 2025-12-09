import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // 1. Impor paket http
import 'dart:convert'; // 2. Impor untuk jsonDecode
import 'post_model.dart'; // 3. Impor model Post baru kita

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  // 4. Kita tidak lagi simpan List, tapi kita simpan "Future"
  // Future adalah "janji" bahwa data (List<Post>) akan datang nanti
  late Future<List<Post>> _futurePosts;

  @override
  void initState() {
    super.initState();
    // 5. Panggil fungsi fetch data SAAT halaman pertama kali dibuka
    _futurePosts = _fetchPosts();
  }

  // 6. FUNGSI UNTUK MENGAMBIL DATA (async)
  Future<List<Post>> _fetchPosts() async {
    // Tentukan URL API-nya
    final url = Uri.parse('https://jsonplaceholder.typicode.com/posts');

    // 'await' berarti "tunggu sampai selesai"
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // 200 = OK (Sukses)
      // 7. Ubah data mentah (String) menjadi List<dynamic>
      final List<dynamic> dataJson = jsonDecode(response.body);

      // 8. Ubah List<dynamic> menjadi List<Post> menggunakan fromJson
      return dataJson.map((json) => Post.fromJson(json)).toList();
    } else {
      // Jika gagal (misal: 404, 500)
      throw Exception('Gagal memuat data dari API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Posts dari API (Internet)")),
      // 9. Gunakan FUTUREBUILDER
      body: FutureBuilder<List<Post>>(
        future:
            _futurePosts, // 10. Beri tahu FutureBuilder "future" mana yg didengar
        builder: (context, snapshot) {
          // 11. Cek status "janji" (Future)
          if (snapshot.connectionState == ConnectionState.waiting) {
            // JIKA MASIH LOADING...
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // JIKA ADA ERROR (misal: tidak ada internet)
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            // JIKA SUKSES DAN DATA SUDAH DATANG!
            final posts = snapshot.data!; // Ambil datanya

            // Tampilkan ListView.builder seperti sebelumnya
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                // Tampilkan data Post
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: CircleAvatar(child: Text(post.id.toString())),
                    title: Text(post.title),
                    subtitle: Text(post.body),
                  ),
                );
              },
            );
          } else {
            // Kasus lain
            return const Center(child: Text("Tidak ada data"));
          }
        },
      ),
      // Tombol Refresh
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Panggil ulang fetch data dan update UI
          setState(() {
            _futurePosts = _fetchPosts();
          });
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
