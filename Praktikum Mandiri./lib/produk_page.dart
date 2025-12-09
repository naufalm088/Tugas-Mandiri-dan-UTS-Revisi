import 'package:flutter/material.dart';
import 'produk_model.dart'; // Impor model kita

// Halaman utama yang berisi list produk
class ProdukPage extends StatelessWidget {
  ProdukPage({super.key});

  // 2. Buat List data statis menggunakan Model
  final List<Produk> products = [
    Produk(
      nama: "Kulkas A",
      deskripsi: "Kulkas 2 pintu, hemat listrik",
      harga: 2500000,
      imageUrl: "https://picsum.photos/id/10/200",
      stok: 5,
    ),
    Produk(
      nama: "TV B",
      deskripsi: "Smart TV 50 inch, 4K",
      harga: 5000000,
      imageUrl: "https://picsum.photos/id/20/200",
      stok: 5,
    ),
    Produk(
      nama: "Mesin Cuci C",
      deskripsi: "Front loading, 7kg",
      harga: 3500000,
      imageUrl: "https://picsum.photos/id/30/200",
      stok: 5,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Produk")),
      // 3. Gunakan ListView.builder
      body: ListView.builder(
        itemCount: products.length, // Tentukan jumlah item
        itemBuilder: (context, index) {
          // Panggil ItemProduk untuk setiap item di list
          return ItemProduk(produk: products[index]);
        },
      ),
    );
  }
}

// Widget terpisah untuk menampilkan satu item produk
// Ini adalah praktik yang baik (memisahkan widget)
class ItemProduk extends StatelessWidget {
  final Produk produk;

  const ItemProduk({super.key, required this.produk});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: Image.network(
          produk.imageUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
        title: Text(
          produk.nama,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(produk.deskripsi),
        trailing: Text(
          "Rp ${produk.harga}",
          style: const TextStyle(color: Colors.green, fontSize: 14),
        ),
        onTap: () {
          // Aksi saat di-tap
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Anda memilih ${produk.nama}")),
          );
        },
      ),
    );
  }
}
