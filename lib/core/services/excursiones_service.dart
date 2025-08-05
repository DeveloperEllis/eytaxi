// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class ExcursionesServiceSupabase{
// static Future<void> handleReservation(Map<String, dynamic> excursion, BuildContext context) async {
//     final user = Supabase.instance.client.auth.currentUser;
//     final result = await showDialog<Map<String, dynamic>>(
//       context: context,
//       builder: (context) => ReservationDialog(
//         excursion: excursion,
//         onReservationConfirmed: (reservationData) async {
//           try {
//             await Supabase.instance.client
//                 .from('reservas_excursiones')
//                 .insert({
//                   'user_id': user.id,
//                   'titulo': excursion['titulo'],
//                   'excursiones_id': excursion['id'],
//                   ...reservationData,
//                 });

//             if (context.mounted) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('¡Reserva realizada con éxito!'),
//                   backgroundColor: Colors.green,
//                 ),
//               );
//             }
//             Navigator.of(context).pop(reservationData);
//           } catch (e) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text('Error al crear la reserva: ${e.toString()}'),
//                 backgroundColor: Colors.red,
//               ),
//             );
//           }
//         },
//       ),
//     );

//     if (result != null) {
//       // La reserva fue exitosa, podrías actualizar algo si es necesario
//     }
//   }
  


// }