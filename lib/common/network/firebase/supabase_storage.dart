import 'dart:io';
import 'package:fit_store/common/network/firebase/storage_service.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService implements StorageService {
  final SupabaseClient client;

  SupabaseStorageService(this.client);

  @override
  Future<String> uploadFile({required File file, required String path}) async {
    final extension = p.extension(file.path);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}$extension';
    final storagePath = '$fileName';

    print("Bucket = $path");
    print("StoragePath = $storagePath");

    final response = await client.storage
        .from(path)
        .upload(
          storagePath,
          file,
          fileOptions: const FileOptions(upsert: true),
        );

    print(response);

    return client.storage.from(path).getPublicUrl(storagePath);
  }
}
