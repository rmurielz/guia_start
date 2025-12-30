import 'package:flutter/material.dart';

/// Widget genérico para búsquedas con dropdown de resultados
///
/// Ejemplo de uso:
/// ```dart
/// SearchableDropdown<ThirdParty>(
///   labelText: 'Buscar organizador',
///   selectedItem: _selectedOrganizer,
///   onSearch: (query) => _thirdPartyRepo.searchThirdPartiesByName(query),
///   onSelected: (organizer) {
///     setState(() => _selectedOrganizer = organizer);
///   },
///   itemBuilder: (organizer) => Text(organizer.name),
///   displayText: (organizer) => organizer.name,
/// )
/// ```
class SearchableDropdown<T> extends StatefulWidget {
  // Etiqueta del campo de búsqueda
  final String labelText;

  // Icono que aparece al inicio del campo de búsqueda
  final IconData? prefixIcon;

  // Elemento seleccionado actualmente
  final T? selectedItem;

  // Función que realiza la búsqueda asíncrona
  // Recibe el texto de búsqueda y devuelve una lista de resultados
  final Future<List<T>> Function(String query) onSearch;

  // Callback cuando se selecciona un elemento
  final void Function(T? item) onSelected;

  // Constructor del widget para cada item en la lista de resultados
  final Widget Function(T item) itemBuilder;

  // Función para obtener el texto a mostrar del elemento seleccionado
  final String Function(T item) displayText;

  // Mensaje a mostrar cuando no hay resultados
  final String? emptyMessage;

  // Altura máxima del dropdown de resultados
  final double maxDropdownHeight;

  const SearchableDropdown({
    super.key,
    required this.labelText,
    required this.onSearch,
    required this.onSelected,
    required this.itemBuilder,
    required this.displayText,
    this.prefixIcon,
    this.selectedItem,
    this.emptyMessage,
    this.maxDropdownHeight = 200,
  });

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<T> _results = [];
  bool _isSearching = false;
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    // Si hay un elemento seleccionado, mostrar su texto en el controlador
    if (widget.selectedItem != null) {
      _controller.text = widget.displayText(widget.selectedItem!);
    }
  }

  @override
  void didUpdateWidget(SearchableDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

// si el elemento seleccionado cambió, actualizar el texto del controlador
    if (widget.selectedItem != oldWidget.selectedItem) {
      if (widget.selectedItem != null) {
        _controller.text = widget.displayText(widget.selectedItem!);
      } else {
        _controller.clear();
      }
      setState(() {
        _results = [];
        _showResults = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _showResults = false;
      });
      return;
    }
    setState(() {
      _isSearching = true;
      _showResults = true;
    });
    try {
      final results = await widget.onSearch(query);

      if (mounted) {
        setState(() {
          _results = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _results = [];
          _isSearching = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error durante la búsqueda: $e')),
        );
      }
    }
  }

  void _selectItem(T item) {
    setState(() {
      _controller.text = widget.displayText(item);
      _results = [];
      _showResults = false;
    });
    widget.onSelected(item);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo de texto para la búsqueda
        TextFormField(
          controller: _controller,
          style: TextStyle(color: colorScheme.tertiary),
          decoration: InputDecoration(
            labelText: widget.labelText,
            prefixIcon:
                widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
            suffixIcon: widget.selectedItem != null
                ? Icon(Icons.check_circle, color: colorScheme.primary)
                : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: colorScheme.primary,
                width: 1.0,
              ),
            ),
          ),
          onChanged: (value) {
            // Si había algo seleccionado, limpiarlo al cambiar el texto
            if (widget.selectedItem != null) {
              widget.onSelected(null); // Notificar que se deseleccionó
            }
            _performSearch(value);
          },
        ),

        // Indicador de carga
        if (_isSearching)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        // Lista de resultados
        if (_showResults && !_isSearching && _results.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: colorScheme.tertiary.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            constraints: BoxConstraints(
              maxHeight: widget.maxDropdownHeight,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final item = _results[index];
                return InkWell(
                  onTap: () => _selectItem(item),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 16.0,
                    ),
                    child: widget.itemBuilder(item),
                  ),
                );
              },
            ),
          ),

        // Mensaje cuando no hay resultados
        if (_showResults && !_isSearching && _results.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.emptyMessage ?? 'No se encontraron resultados.',
              style: TextStyle(
                  color: colorScheme.tertiary.withOpacity(0.6), fontSize: 14),
            ),
          ),
      ],
    );
  }
}
