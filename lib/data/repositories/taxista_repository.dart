import 'package:eytaxi/data/sources/supabase_taxista_source.dart';
import 'package:eytaxi/models/taxista_model.dart';

class TaxistaRepository {
	final SupabaseTaxistaSource _source = SupabaseTaxistaSource();

	Future<List<Driver>> fetchAllDrivers() {
		return _source.fetchAllDrivers();
	}
}
