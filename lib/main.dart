// lib/main.dart
import 'package:flutter/material.dart';
import 'edit_inventory_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Simple Inventory App",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue, // Puedes mantener este o cambiarlo si quieres
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<Map<String, dynamic>> _inventoryItems = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  final TextEditingController _inventoryIdController = TextEditingController();
  final TextEditingController _videogameIdController = TextEditingController();
  final TextEditingController _stockQuantityController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateLastUpdatedController = TextEditingController();
  final TextEditingController _unitCostController = TextEditingController();
  final TextEditingController _supplierController = TextEditingController();

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

  void _addInventoryItem() {
    _inventoryIdController.clear();
    _videogameIdController.clear();
    _stockQuantityController.clear();
    _locationController.clear();
    _dateLastUpdatedController.clear();
    _unitCostController.clear();
    _supplierController.clear();

    final DateTime initialDate = DateTime.now();
    _dateLastUpdatedController.text = "${initialDate.day}/${initialDate.month}/${initialDate.year}";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Artículo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _inventoryIdController, decoration: const InputDecoration(labelText: 'Inventario ID')),
              TextField(controller: _videogameIdController, decoration: const InputDecoration(labelText: 'Videojuego ID')),
              TextField(controller: _stockQuantityController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cantidad en Stock')),
              TextField(controller: _locationController, decoration: const InputDecoration(labelText: 'Ubicación')),
              GestureDetector(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: initialDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
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
                      labelText: 'Fecha de Actualización (DD/MM/AAAA)',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
              TextField(controller: _unitCostController, keyboardType: TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Costo Unitario')),
              TextField(controller: _supplierController, decoration: const InputDecoration(labelText: 'Proveedor')),
            ].map((widget) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: widget,
            )).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
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
              }

              if (inventoryId.isNotEmpty && videogameId.isNotEmpty && stockQuantity != null && location.isNotEmpty && unitCost != null && selectedDate != null && supplier.isNotEmpty) {
                setState(() {
                  _inventoryItems.insert(0, {
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'inventoryId': inventoryId,
                    'videojuegoId': videogameId,
                    'cantidadStock': stockQuantity,
                    'ubicacionAlmacen': location,
                    'fechaUltimaActualizacion': selectedDate,
                    'costoUnitario': unitCost,
                    'proveedor': supplier,
                  });
                  _listKey.currentState?.insertItem(0, duration: const Duration(milliseconds: 500));
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor, llena todos los campos.')),
                );
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _removeInventoryItem(int index) {
    final Map<String, dynamic> removedItem = _inventoryItems.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => SizeTransition(
        sizeFactor: animation,
        axisAlignment: -1.0,
        child: _buildInventoryCard(removedItem),
      ),
      duration: const Duration(milliseconds: 400),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Artículo "${removedItem["inventoryId"] ?? "N/A"}" eliminado')),
    );
  }

  void _editInventoryItem(int index) async {
    final Map<String, dynamic> itemToEdit = Map<String, dynamic>.from(_inventoryItems[index]);

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditInventoryScreen(item: itemToEdit),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _inventoryItems[index] = result;
      });
    }
  }

  Widget _buildInventoryCard(Map<String, dynamic> item) {
    final String inventoryId = item['inventoryId'] as String? ?? 'N/A';
    final String videogameId = item['videojuegoId'] as String? ?? 'N/A';
    final String stockQuantity = item['cantidadStock']?.toString() ?? 'N/A';
    final String location = item['ubicacionAlmacen'] as String? ?? 'N/A';
    final String unitCost = item['costoUnitario']?.toString() ?? 'N/A';
    final String supplier = item['proveedor'] as String? ?? 'N/A';

    final DateTime? date = item['fechaUltimaActualizacion'] as DateTime?;
    final String formattedDate = date != null
        ? "${date.day}/${date.month}/${date.year}"
        : 'N/A';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Dismissible(
        key: Key(item['id']),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Confirmar Eliminación'),
              content: Text('¿Estás seguro de eliminar el artículo "${item["inventoryId"] ?? "N/A"}"?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Eliminar'),
                ),
              ],
            ),
          ) ?? false;
        },
        onDismissed: (direction) {
          final int index = _inventoryItems.indexWhere((element) => element['id'] == item['id']);
          if (index != -1) {
            _removeInventoryItem(index);
          }
        },
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        child: ListTile(
          title: Text('ID Inventario: $inventoryId'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Videojuego: $videogameId'),
              Text('Stock: $stockQuantity'),
              Text('Ubicación: $location'),
              Text('Fecha Actualización: $formattedDate'),
              Text('Costo Unitario: \$$unitCost'),
              Text('Proveedor: $supplier'),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              final int index = _inventoryItems.indexWhere((element) => element['id'] == item['id']);
              if (index != -1) {
                _editInventoryItem(index);
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // Color de fondo del AppBar
        title: const Text(
          "Ariel Rodriguez",
          style: TextStyle(color: Colors.white), // Color del texto del título
        ),
      ),
      body: _inventoryItems.isEmpty
          ? const Center(
              // ELIMINAMOS EL TEXTO DEL CENTRO SI NO HAY ITEMS
              // child: Text('No hay artículos en el inventario. Agrega uno!'),
            )
          : AnimatedList(
              key: _listKey,
              padding: const EdgeInsets.all(8.0),
              initialItemCount: _inventoryItems.length,
              itemBuilder: (context, index, animation) {
                final item = _inventoryItems[index];
                return SizeTransition(
                  sizeFactor: animation,
                  child: _buildInventoryCard(item),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addInventoryItem,
        child: const Icon(Icons.add),
      ),
    );
  }
}