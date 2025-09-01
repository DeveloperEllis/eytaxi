
import 'package:eytaxi/data/sources/guest_remote_datasource.dart';
import 'package:eytaxi/data/models/guest_contact_model.dart';

class ExcursionRepository {
  final GuestContactRemoteDataSource remoteDataSource;
  ExcursionRepository(this.remoteDataSource);

  Future<void> createExcursionReservation(GuestContact contact) async {
    await remoteDataSource.createGuestContact(contact);
  }
}