/// Screen for creating, managing, and selecting custom dare lists.
///
/// Users can:
/// - Create new dare lists.
/// - Add dares to their lists.
/// - Edit or delete existing dares.
/// - Delete entire dare lists.
/// - Select a list to start a game with (navigates to ChooserScreen with custom dares).
///
/// State is managed locally using `StatefulWidget` and `SharedPreferences` for persistence.
/// Includes loading indicators and messages for empty states.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Though not explicitly used, good to keep if dealing with complex JSON in shared_prefs
import 'dart:math'; // For potential future use if randomizing here, or just good practice if dealing with lists
import 'package:audioplayers/audioplayers.dart'; // Added audioplayers
import '../../../finger_chooser/presentation/screens/chooser_screen.dart'; // Navigate to ChooserScreen
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // For localization

class CustomPlayWizardScreen extends StatefulWidget {
  const CustomPlayWizardScreen({super.key});

  @override
  State<CustomPlayWizardScreen> createState() => _CustomPlayWizardScreenState();
}

class _CustomPlayWizardScreenState extends State<CustomPlayWizardScreen> {
  List<String> _dareLists = [];
  String? _selectedList;
  Map<String, List<String>> _dareListMap = {}; // Stores dares for each list

  TextEditingController _listNameController = TextEditingController();
  TextEditingController _dareController = TextEditingController();

  bool get _isListNameEmpty => _listNameController.text.trim().isEmpty;
  bool get _isDareEmpty => _dareController.text.trim().isEmpty;
  bool get _noListSelected => _selectedList == null;
  bool _isLoading = true; // Added for loading state

  final AudioPlayer _buttonClickPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadDareLists();
  }

  void _playButtonClickSound() {
    _buttonClickPlayer.play(AssetSource('sounds/button_click.mp3'));
  }

  Future<void> _loadDareLists() async {
    setState(() {
      _isLoading = true;
    });
    // Simulate a small delay for loading if needed, SharedPreferences is usually fast
    // await Future.delayed(const Duration(milliseconds: 500));
    final prefs = await SharedPreferences.getInstance();
    // Ensure that setState is called after async operation, but before using the data
    if (!mounted) return;
    _dareLists = prefs.getStringList('custom_dare_lists') ?? [];
    _dareListMap = {};
    for (String listName in _dareLists) {
      List<String> dares = prefs.getStringList('dares_$listName') ?? [];
      _dareListMap[listName] = dares;
    }
    if (_dareLists.isNotEmpty) {
      _selectedList = _dareLists.first;
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveDareLists() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('custom_dare_lists', _dareLists);
    for (String listName in _dareListMap.keys) {
      await prefs.setStringList('dares_$listName', _dareListMap[listName]!);
    }
  }

  void _createList() {
    HapticFeedback.selectionClick();
    _playButtonClickSound();
    final localizations = AppLocalizations.of(context)!;
    if (_isListNameEmpty) return;
    final listName = _listNameController.text.trim();
    if (_dareLists.contains(listName)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.listAlreadyExistsError(listName))),
      );
      return;
    }
    setState(() {
      _dareLists.add(listName);
      _dareListMap[listName] = [];
      _selectedList = listName;
      _listNameController.clear();
    });
    _saveDareLists();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(localizations.listCreatedSuccess(listName))),
    );
  }

  void _addDare() {
    HapticFeedback.selectionClick();
    _playButtonClickSound();
    if (_isDareEmpty || _noListSelected) return;
    final dareText = _dareController.text.trim();
    setState(() {
      _dareListMap[_selectedList!]!.add(dareText);
      _dareController.clear();
    });
    _saveDareLists();
  }

  void _editDare(int index) {
    // Haptic for IconButton will be handled at call site
    if (_noListSelected) return;
    final currentDare = _dareListMap[_selectedList!]![index];
    TextEditingController editController = TextEditingController(text: currentDare);
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(localizations.editDareTitle),
          content: TextField(
            controller: editController,
            autofocus: true,
            decoration: InputDecoration(hintText: localizations.editDareHint),
          ),
          actions: [
            TextButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                // Optionally play sound for dialog buttons too
                Navigator.of(context).pop();
              },
              child: Text(localizations.cancelButton),
            ),
            ElevatedButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                _playButtonClickSound(); // For main action button
                if (editController.text.trim().isNotEmpty) {
                  setState(() {
                    _dareListMap[_selectedList!]![index] = editController.text.trim();
                  });
                  _saveDareLists();
                  Navigator.of(context).pop();
                }
              },
              child: Text(localizations.saveButton),
            ),
          ],
        );
      },
    );
  }

  void _deleteDare(int index) {
    if (_noListSelected) return;
    setState(() {
      _dareListMap[_selectedList!]!.removeAt(index);
    });
    _saveDareLists();
  }

  void _deleteList() {
    if (_noListSelected) return;
    final listToDelete = _selectedList!;
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(localizations.deleteListDialogTitle(listToDelete)),
          content: Text(localizations.deleteListDialogContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations.cancelButton),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                HapticFeedback.selectionClick();
                _playButtonClickSound(); // For main action button
                setState(() {
                  _dareLists.remove(listToDelete);
                  _dareListMap.remove(listToDelete);
                  if (_dareLists.isNotEmpty) {
                    _selectedList = _dareLists.first;
                  } else {
                    _selectedList = null;
                  }
                });
                _saveDareLists();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(localizations.listDeletedSuccess(listToDelete))),
                );
              },
              child: Text(localizations.deleteButton),
            ),
          ],
        );
      },
    );
  }


  @override
  // Helper method to build the dare list management section
  Widget _buildDareListManagementSection(BuildContext context, AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(localizations.dareListsTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _listNameController,
                decoration: InputDecoration(
                  hintText: localizations.enterNewListNameHint,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isListNameEmpty ? null : _createList,
              child: Text(localizations.createListButton),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_dareLists.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Text(localizations.noDareListsFoundMessage, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
            )
          )
        else
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedList,
                  hint: Text(localizations.selectAListHint),
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedList = newValue;
                    });
                  },
                  items: _dareLists.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              if (!_noListSelected) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.delete_forever, color: Colors.red[700]),
                  tooltip: localizations.deleteSelectedListTooltip,
                  onPressed: _deleteList,
                ),
              ]
            ],
          ),
        const SizedBox(height: 24),
      ],
    );
  }

  // Helper method to build the dare entry and list section
  Widget _buildDareDetailsSection(BuildContext context, AppLocalizations localizations, List<String> currentDares) {
    if (_dareLists.isEmpty || _noListSelected) {
      return Container(); // Don't show this section if no list is selected or no lists exist
    }
    return Expanded( // This Expanded widget is crucial for the ListView.builder
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(localizations.daresInListTitle(_selectedList!), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _dareController,
                  decoration: InputDecoration(
                    hintText: localizations.enterNewDareHint,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isDareEmpty || _noListSelected ? null : _addDare,
                child: Text(localizations.addDareButton),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: currentDares.isEmpty
                ? Center(child: Text(localizations.noDaresInListMessage))
                : ListView.builder(
                    itemCount: currentDares.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ListTile(
                          title: Text(currentDares[index]),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                tooltip: localizations.editDareTitle,
                                onPressed: () {
                                  HapticFeedback.selectionClick();
                                  _editDare(index);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: localizations.deleteDareTooltip,
                                onPressed: () {
                                  HapticFeedback.selectionClick();
                                  _deleteDare(index);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
          if (!_noListSelected && currentDares.isNotEmpty)
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: Text(localizations.startGameButtonTitle(_selectedList!)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 16)
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  _playButtonClickSound();
                  if (_selectedList != null && _dareListMap.containsKey(_selectedList!) && _dareListMap[_selectedList!]!.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChooserScreen(
                          customDares: _dareListMap[_selectedList!]!,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    List<String> currentDares = _selectedList != null && _dareListMap.containsKey(_selectedList)
        ? _dareListMap[_selectedList!]!
        : [];

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(localizations.customPlayWizardTitle),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.customPlayWizardTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDareListManagementSection(context, localizations),
            // Conditionally build the dare details section
            // It needs an Expanded wrapper if it contains an Expanded ListView.builder
            // So, we ensure that _buildDareDetailsSection itself is Expanded if it's going to be visible.
            if (_dareLists.isNotEmpty && !_noListSelected)
              _buildDareDetailsSection(context, localizations, currentDares)
            else if (_dareLists.isNotEmpty && _noListSelected)
              Padding( // Optional: Prompt to select a list if lists exist but none selected
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Center(child: Text(localizations.selectAListHint, style: Theme.of(context).textTheme.titleMedium)),
              ),
            // Other elements like global save button could go here if not part of a conditionally expanded section
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _listNameController.dispose();
    _dareController.dispose();
    _buttonClickPlayer.dispose();
    super.dispose();
  }
}
