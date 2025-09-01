import 'package:eytaxi/data/models/guest_contact_model.dart';
import 'package:eytaxi/features/excursiones/data/datasources/excursion_remote_datasource.dart';
import 'package:eytaxi/features/excursiones/data/models/reserva_excusion_model.dart';

class ExcursionRepository {
  final ExcursionRemoteDataSource remoteDataSource;
  ExcursionRepository(this.remoteDataSource);

  Future<void> createExcursionReservation(ReservaExc reserva, GuestContact contact) async {
    await remoteDataSource.createExcursionReservation(reserva, contact);
  }

  Future<List<ReservaExc>> getExcursionReservations() async {
    return await remoteDataSource.getExcursionReservations();
  }
}
