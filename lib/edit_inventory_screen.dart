import 'package:flutter/material.dart';

class EditInventoryScreen extends StatefulWidget {
  final Map<String, dynamic> item; // Recibe el item a editar

  const EditInventoryScreen({Key? key, required this.item}) : super(key: key);

  @override
  State<EditInventoryScreen> createState() => _EditInventoryScreenState();
}

class _EditInventoryScreenState extends State<EditInventoryScreen> {
  final TextEditingController _inventoryIdController = TextEditingController();
  final TextEditingController _videogameIdController = TextEditingController();
  final TextEditingController _stockQuantityController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateLastUpdatedController = TextEditingController();
  final TextEditingController _unitCostController = TextEditingController();
  final TextEditingController _supplierController = TextEditingController();


  @override
  void initState() {
    super.initState();
    // Cargar los datos del item en los controladores al inicializar
    _inventoryIdController.text = widget.item['inventoryId'] as String? ?? '';
    _videogameIdController.text = widget.item['videojuegoId'] as String? ?? '';
    _stockQuantityController.text = widget.item['cantidadStock']?.toString() ?? '';
    _locationController.text = widget.item['ubicacionAlmacen'] as String? ?? '';
    _unitCostController.text = widget.item['costoUnitario']?.toString() ?? '';
    _supplierController.text = widget.item['proveedor'] as String? ?? '';

    final DateTime? date = widget.item['fechaUltimaActualizacion'] as DateTime?;
    if (date != null) {
      _dateLastUpdatedController.text = "${date.day}/${date.month}/${date.year}";
    } else {
      _dateLastUpdatedController.text = '';
    }
  }

  @override
  void dispose() {
    _inventoryIdController.dispose();
    _videogameIdController.dispose();
    _stockQuantityController.dispose();
    _locationController.dispose();
    _dateLastUpdatedController.dispose();
    _unitCostController.dispose();
    _supplierController.dispose();
    super.dispose();
  }

  void _updateInventoryItem() {
    final String inventoryId = _inventoryIdController.text.trim();
    final String videogameId = _videogameIdController.text.trim();
    final int? stockQuantity = int.tryParse(_stockQuantityController.text.trim());
    final String location = _locationController.text.trim();
    final double? unitCost = double.tryParse(_unitCostController.text.trim());
    final String supplier = _supplierController.text.trim();

    DateTime? selectedDate;
    try {
        final parts = _dateLastUpdatedController.text.split('/');
        if (parts.length == 3) {
            final day = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            final year = int.parse(parts[2]);
            selectedDate = DateTime(year, month, day);
        }
    } catch (e) {
        selectedDate = null;
        print('Error al parsear la fecha en edición: $e');
    }

    if (inventoryId.isNotEmpty && videogameId.isNotEmpty && stockQuantity != null && location.isNotEmpty && unitCost != null && selectedDate != null && supplier.isNotEmpty) {
      // Devolver los datos actualizados a la pantalla anterior
      Navigator.pop(context, {
        'id': widget.item['id'], // Mantener el mismo ID para el Dismissible
        'inventoryId': inventoryId,
        'videojuegoId': videogameId,
        'cantidadStock': stockQuantity,
        'ubicacionAlmacen': location,
        'fechaUltimaActualizacion': selectedDate,
        'costoUnitario': unitCost,
        'proveedor': supplier,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, llena todos los campos obligatorios para actualizar, asegúrate que cantidad/costo sean números y la fecha sea válida.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Artículo de Inventario'),
        // Los estilos se heredan del tema principal
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _inventoryIdController,
              decoration: const InputDecoration(labelText: 'Inventario ID'),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _videogameIdController,
              decoration: const InputDecoration(labelText: 'Videojuego ID'),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _stockQuantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Cantidad en Stock'),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Ubicación en Almacén'),
            ),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: () async {
                DateTime initialDateForPicker;
                try {
                  // Intenta parsear la fecha actual del controlador para usarla como initialDate
                  final parts = _dateLastUpdatedController.text.split('/');
                  initialDateForPicker = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
                } catch (e) {
                  initialDateForPicker = DateTime.now(); // Si hay error, usa la fecha actual
                }

                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: initialDateForPicker,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                  builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: Theme.of(context).hintColor, // Color del selector de fecha
                            onPrimary: Colors.white, // Color del texto en el selector de fecha
                            onSurface: Colors.black87, // Color de los números y texto de la fecha
                          ),
                          dialogBackgroundColor: Theme.of(context).dialogTheme.backgroundColor, // Fondo del picker
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context).hintColor, // Color de texto de los botones del picker (Cancelar, OK)
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    },
                );
                if (picked != null) {
                  setState(() {
                    _dateLastUpdatedController.text = "${picked.day}/${picked.month}/${picked.year}";
                  });
                }
              },
              child: AbsorbPointer(
                child: TextField(
                  controller: _dateLastUpdatedController,
                  decoration: const InputDecoration(
                    labelText: 'Fecha de Última Actualización (DD/MM/AAAA)',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _unitCostController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Costo Unitario'),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _supplierController,
              decoration: const InputDecoration(labelText: 'Proveedor'),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateInventoryItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).hintColor, // Botón azul claro
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Actualizar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}