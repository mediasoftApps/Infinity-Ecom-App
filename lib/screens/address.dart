import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infinity_ecom_app/l10n/app_localizations.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../custom/box_decorations.dart';
import '../custom/btn.dart';
import '../custom/lang_text.dart';
import '../custom/toast_component.dart';
import '../data_model/business_setting_response.dart';
import '../data_model/city_response.dart';
import '../data_model/country_response.dart';
import '../data_model/state_response.dart';
import '../helpers/shared_value_helper.dart';
import '../helpers/shimmer_helper.dart';
import '../my_theme.dart';
import '../repositories/address_repository.dart';
import '../repositories/business_setting_repository.dart';
import 'map_location.dart';

class Address extends StatefulWidget {
  final bool from_shipping_info;
  const Address({super.key, this.from_shipping_info = false});

  @override
  State<Address> createState() => _AddressState();
}

class _AddressState extends State<Address> {
  final ScrollController _mainScrollController = ScrollController();
  bool _showStateField = true;

  int? _default_shipping_address = 0;
  City? _selected_city;
  Country? _selected_country;
  MyState? _selected_state;
  City? _selected_area;

  bool _isInitial = true;
  final List<dynamic> _shippingAddressList = [];
  bool _isAreaRequired = false;

  //controllers for add purpose
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();

  //for update purpose
  final List<TextEditingController> _addressControllerListForUpdate = [];
  final List<TextEditingController> _postalCodeControllerListForUpdate = [];
  final List<TextEditingController> _phoneControllerListForUpdate = [];
  final List<TextEditingController> _cityControllerListForUpdate = [];
  final List<TextEditingController> _stateControllerListForUpdate = [];
  final List<TextEditingController> _countryControllerListForUpdate = [];
  final List<TextEditingController> _areaControllerListForUpdate = [];

  final List<City?> _selected_city_list_for_update = [];
  final List<MyState?> _selected_state_list_for_update = [];
  final List<Country> _selected_country_list_for_update = [];
  final List<City?> _selected_area_list_for_update = [];

  @override
  void initState() {
    super.initState();
    if (is_logged_in.$ == true) {
      fetchAll();
    }
  }

  fetchAll() {
    fetchShippingAddressList();
  }

  fetchShippingAddressList() async {
    var addressResponse = await AddressRepository().getAddressList();
    _shippingAddressList.addAll(addressResponse.addresses);
    _isInitial = false;
    if (_shippingAddressList.isNotEmpty) {
      for (var address in _shippingAddressList) {
        if (address.set_default == 1) {
          _default_shipping_address = address.id;
        }
        _addressControllerListForUpdate.add(
          TextEditingController(text: address.address),
        );
        _postalCodeControllerListForUpdate.add(
          TextEditingController(text: address.postal_code),
        );
        _phoneControllerListForUpdate.add(
          TextEditingController(text: address.phone),
        );
        _countryControllerListForUpdate.add(
          TextEditingController(text: address.country_name),
        );
        _stateControllerListForUpdate.add(
          TextEditingController(text: address.state_name),
        );
        _cityControllerListForUpdate.add(
          TextEditingController(text: address.city_name),
        );
        _areaControllerListForUpdate.add(
          TextEditingController(text: address.area_name),
        );
        _selected_country_list_for_update.add(
          Country(id: address.country_id, name: address.country_name),
        );
        _selected_state_list_for_update.add(
          MyState(id: address.state_id, name: address.state_name),
        );
        _selected_city_list_for_update.add(
          City(id: address.city_id, name: address.city_name),
        );
        _selected_area_list_for_update.add(
          City(id: address.area_id, name: address.area_name),
        );
      }
    }
    setState(() {});
  }

  reset() {
    _default_shipping_address = 0;
    _shippingAddressList.clear();
    _isInitial = true;
    _addressController.clear();
    _postalCodeController.clear();
    _phoneController.clear();
    _countryController.clear();
    _stateController.clear();
    _cityController.clear();
    _areaController.clear();
    _addressControllerListForUpdate.clear();
    _postalCodeControllerListForUpdate.clear();
    _phoneControllerListForUpdate.clear();
    _countryControllerListForUpdate.clear();
    _stateControllerListForUpdate.clear();
    _cityControllerListForUpdate.clear();
    _areaControllerListForUpdate.clear();
    _selected_city_list_for_update.clear();
    _selected_state_list_for_update.clear();
    _selected_country_list_for_update.clear();
    _selected_area_list_for_update.clear();
    setState(() {});
  }

  Future<void> _onRefresh() async {
    reset();
    if (is_logged_in.$ == true) {
      fetchAll();
    }
  }

  onPopped(value) async {
    reset();
    fetchAll();
  }

  afterAddingAnAddress() {
    reset();
    fetchAll();
  }

  afterDeletingAnAddress() {
    reset();
    fetchAll();
  }

  afterUpdatingAnAddress() {
    reset();
    fetchAll();
  }

  onAddressSwitch(index) async {
    var addressMakeDefaultResponse =
        await AddressRepository().getAddressMakeDefaultResponse(index);

    if (addressMakeDefaultResponse.result == false) {
      ToastComponent.showDialog(addressMakeDefaultResponse.message);
      return;
    }
    ToastComponent.showDialog(addressMakeDefaultResponse.message);
    setState(() {
      _default_shipping_address = index;
    });
  }

  onPressDelete(id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding: EdgeInsets.only(
          top: 16.0,
          left: 2.0,
          right: 2.0,
          bottom: 2.0,
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Text(
            AppLocalizations.of(context)!.are_you_sure_to_remove_this_address,
            maxLines: 3,
            style: TextStyle(color: MyTheme.font_grey, fontSize: 14),
          ),
        ),
        actions: [
          Btn.basic(
            child: Text(
              AppLocalizations.of(context)!.cancel_ucf,
              style: TextStyle(color: MyTheme.medium_grey),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
          ),
          Btn.basic(
            color: MyTheme.soft_accent_color,
            child: Text(
              AppLocalizations.of(context)!.confirm_ucf,
              style: TextStyle(color: MyTheme.dark_grey),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              confirmDelete(id);
            },
          ),
        ],
      ),
    );
  }

  confirmDelete(id) async {
    var addressDeleteResponse =
        await AddressRepository().getAddressDeleteResponse(id);

    if (addressDeleteResponse.result == false) {
      ToastComponent.showDialog(addressDeleteResponse.message);
      return;
    }
    ToastComponent.showDialog(addressDeleteResponse.message);
    afterDeletingAnAddress();
  }

  onAddressAdd(context) async {
    var address = _addressController.text.toString();
    var postalCode = _postalCodeController.text.toString();
    var phone = _phoneController.text.toString();

    if (address == "") {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.enter_address_ucf,
      );
      return;
    }
    if (_selected_country == null) {
      ToastComponent.showDialog(AppLocalizations.of(context)!.select_a_country);
      return;
    }

    if (_showStateField && _selected_state == null) {
      ToastComponent.showDialog(AppLocalizations.of(context)!.select_a_state);
      return;
    }

    if (_selected_city == null) {
      ToastComponent.showDialog(AppLocalizations.of(context)!.select_a_city);
      return;
    }

    if (_isAreaRequired && _selected_area == null) {
      ToastComponent.showDialog("Please select an Area");
      return;
    }

    var addressAddResponse = await AddressRepository().getAddressAddResponse(
      address: address,
      country_id: _selected_country!.id,
      state_id: _selected_state?.id ?? 0,
      city_id: _selected_city!.id,
      area_id: _selected_area?.id,
      postal_code: postalCode,
      phone: phone,
    );

    if (addressAddResponse.result == false) {
      ToastComponent.showDialog(addressAddResponse.message);
      return;
    }

    ToastComponent.showDialog(addressAddResponse.message);
    Navigator.of(context, rootNavigator: true).pop();
    afterAddingAnAddress();
  }

  onAddressUpdate(context, index, id) async {
    var address = _addressControllerListForUpdate[index].text.toString();
    var postalCode = _postalCodeControllerListForUpdate[index].text.toString();
    var phone = _phoneControllerListForUpdate[index].text.toString();

    if (address == "") {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.enter_address_ucf,
      );
      return;
    }

    if (_showStateField && _selected_state_list_for_update[index] == null) {
      ToastComponent.showDialog(AppLocalizations.of(context)!.select_a_state);
      return;
    }
    if (_selected_city_list_for_update[index] == null) {
      ToastComponent.showDialog(AppLocalizations.of(context)!.select_a_city);
      return;
    }

    if (_isAreaRequired && _selected_area_list_for_update[index] == null) {
      ToastComponent.showDialog("Please select an Area");
      return;
    }

    var addressUpdateResponse =
        await AddressRepository().getAddressUpdateResponse(
      id: id,
      address: address,
      country_id: _selected_country_list_for_update[index].id,
      state_id: _selected_state_list_for_update[index]?.id ?? 0,
      city_id: _selected_city_list_for_update[index]!.id,
      area_id: _selected_area_list_for_update[index]?.id,
      postal_code: postalCode,
      phone: phone,
    );

    if (addressUpdateResponse.result == false) {
      ToastComponent.showDialog(addressUpdateResponse.message);
      return;
    }
    ToastComponent.showDialog(addressUpdateResponse.message);
    Navigator.of(context, rootNavigator: true).pop();
    afterUpdatingAnAddress();
  }

  onSelectCityDuringAdd(city, setModalState) async {
    if (_selected_city != null && city.id == _selected_city!.id) {
      setModalState(() {
        _cityController.text = city.name;
      });
      return;
    }
    _selected_city = city;
    _selected_area = null;

    var areaResponse = await AddressRepository().getAriaListByCity(
      city_id: _selected_city!.id,
    );
    _isAreaRequired = areaResponse.cities.isNotEmpty;

    setModalState(() {
      _cityController.text = city.name;
      _areaController.text = "";
    });
  }

  onSelectCityDuringUpdate(index, city, setModalState) async {
    if (_selected_city_list_for_update[index] != null &&
        city.id == _selected_city_list_for_update[index]!.id) {
      setModalState(() {
        _cityControllerListForUpdate[index].text = city.name;
      });
      return;
    }
    _selected_city_list_for_update[index] = city;
    _selected_area_list_for_update[index] = null;

    var areaResponse = await AddressRepository().getAriaListByCity(
      city_id: city.id,
    );
    _isAreaRequired = areaResponse.cities.isNotEmpty;

    setModalState(() {
      _cityControllerListForUpdate[index].text = city.name;
      _areaControllerListForUpdate[index].text = "";
    });
  }

  onSelectCountryDuringAdd(country, setModalState) {
    if (_selected_country != null && country.id == _selected_country!.id) {
      setModalState(() => _countryController.text = country.name);
      return;
    }
    _selected_country = country;
    _selected_state = null;
    _selected_city = null;
    _selected_area = null;
    _isAreaRequired = false;
    setState(() {});

    setModalState(() {
      _countryController.text = country.name;
      _stateController.text = "";
      _cityController.text = "";
      _areaController.text = "";
    });
  }

  onSelectStateDuringAdd(state, setModalState) {
    if (_selected_state != null && state.id == _selected_state!.id) {
      setModalState(() => _stateController.text = state.name);
      return;
    }
    _selected_state = state;
    _selected_city = null;
    _selected_area = null;
    _isAreaRequired = false;
    setState(() {});
    setModalState(() {
      _stateController.text = state.name;
      _cityController.text = "";
      _areaController.text = "";
    });
  }

  onSelectAreaDuringAdd(area, setModalState) {
    if (_selected_area != null && area.id == _selected_area!.id) {
      setModalState(() => _areaController.text = area.name);
      return;
    }
    _selected_area = area;
    setModalState(() => _areaController.text = area.name);
  }

  onSelectCountryDuringUpdate(index, country, setModalState) {
    if (country.id == _selected_country_list_for_update[index].id) {
      setModalState(
        () => _countryControllerListForUpdate[index].text = country.name,
      );
      return;
    }
    _selected_country_list_for_update[index] = country;
    _selected_state_list_for_update[index] = null;
    _selected_city_list_for_update[index] = null;
    _selected_area_list_for_update[index] = null;
    _isAreaRequired = false;
    setState(() {});

    setModalState(() {
      _countryControllerListForUpdate[index].text = country.name;
      _stateControllerListForUpdate[index].text = "";
      _cityControllerListForUpdate[index].text = "";
      _areaControllerListForUpdate[index].text = "";
    });
  }

  onSelectStateDuringUpdate(index, state, setModalState) {
    if (_selected_state_list_for_update[index] != null &&
        state.id == _selected_state_list_for_update[index]!.id) {
      setModalState(
        () => _stateControllerListForUpdate[index].text = state.name,
      );
      return;
    }
    _selected_state_list_for_update[index] = state;
    _selected_city_list_for_update[index] = null;
    _selected_area_list_for_update[index] = null;
    _isAreaRequired = false;
    setState(() {});
    setModalState(() {
      _stateControllerListForUpdate[index].text = state.name;
      _cityControllerListForUpdate[index].text = "";
      _areaControllerListForUpdate[index].text = "";
    });
  }

  onSelectAreaDuringUpdate(index, area, setModalState) {
    if (_selected_area_list_for_update[index] != null &&
        area.id == _selected_area_list_for_update[index]!.id) {
      setModalState(() => _areaControllerListForUpdate[index].text = area.name);
      return;
    }
    _selected_area_list_for_update[index] = area;
    setModalState(() => _areaControllerListForUpdate[index].text = area.name);
  }

  _handleAddressAction({required BuildContext context, int? listIndex}) async {
    var countryResponse = await AddressRepository().getCountryList(name: "");
    if (!context.mounted) return;
    var settingsResponse =
        await BusinessSettingRepository().getBusinessSettingList();
    var hasStateDataList = (settingsResponse.data ?? [])
        .where((setting) => setting.type == "has_state")
        .toList();
    Datum? hasStateData =
        hasStateDataList.isNotEmpty ? hasStateDataList.first : null;
    bool showStateField = hasStateData?.value == "1";

    setState(() {
      _showStateField = showStateField;
    });
    _isAreaRequired = false;

    bool showCountryField = countryResponse.countries.length != 1;

    if (listIndex == null) {
      _addressController.clear();
      _postalCodeController.clear();
      _phoneController.clear();

      _countryController.clear();
      _selected_country = null;

      _stateController.clear();
      _selected_state = null;

      _cityController.clear();
      _selected_city = null;

      _areaController.clear();
      _selected_area = null;

      if (!showCountryField && countryResponse.countries.isNotEmpty) {
        final singleCountry = countryResponse.countries.first;
        _selected_country = singleCountry;
        _countryController.text = singleCountry.name;
      }
      buildShowAddFormDialog(context, showCountryField);
    } else {
      var city = _selected_city_list_for_update[listIndex];
      if (city != null) {
        var areaResponse = await AddressRepository().getAriaListByCity(
          city_id: city.id,
        );
        if (context.mounted) {
          setState(() {
            _isAreaRequired = areaResponse.cities.isNotEmpty;
          });
        }
      }
      buildShowUpdateFormDialog(context, listIndex, showCountryField);
    }
  }

  _tabOption(int index, listIndex) {
    switch (index) {
      case 0:
        _handleAddressAction(context: context, listIndex: listIndex);
        break;
      case 1:
        onPressDelete(_shippingAddressList[listIndex].id);
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                MapLocation(address: _shippingAddressList[listIndex]),
          ),
        ).then((value) => onPopped(value));
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.mainColor,
      appBar: buildAppBar(context),
      bottomNavigationBar: buildBottomAppBar(context),
      body: RefreshIndicator(
        color: MyTheme.accent_color,
        backgroundColor: Colors.white,
        onRefresh: _onRefresh,
        displacement: 0,
        child: CustomScrollView(
          controller: _mainScrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 05, 20, 16),
                  child: Btn.minWidthFixHeight(
                    minWidth: MediaQuery.of(context).size.width - 16,
                    height: 90,
                    color: MyTheme.accent_color.withValues(alpha: 0.12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(color: MyTheme.accent_color, width: 1.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.add_new_address,
                          style: TextStyle(
                            fontSize: 13,
                            color: MyTheme.dark_font_grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Icon(
                          Icons.add_circle_outline,
                          color: MyTheme.accent_color,
                          size: 30,
                        ),
                      ],
                    ),
                    onPressed: () {
                      _handleAddressAction(context: context);
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: buildAddressList(),
                ),
                SizedBox(height: 100),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Future buildShowAddFormDialog(BuildContext context, bool showCountryField) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              insetPadding: EdgeInsets.symmetric(horizontal: 10),
              contentPadding: EdgeInsets.only(
                top: 23.0,
                left: 20.0,
                right: 20.0,
                bottom: 2.0,
              ),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: Text(
                          "${AppLocalizations.of(context)!.address_ucf} *",
                          style: TextStyle(
                            color: Color(0xff3E4447),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14.0),
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            controller: _addressController,
                            autofocus: false,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            decoration: buildAddressInputDecoration(
                              context,
                              AppLocalizations.of(context)!.enter_address_ucf,
                            ),
                          ),
                        ),
                      ),
                      if (showCountryField) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            "${AppLocalizations.of(context)!.country_ucf} *",
                            style: TextStyle(
                              color: Color(0xff3E4447),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14.0),
                          child: SizedBox(
                            height: 40,
                            child: TypeAheadField(
                              controller: _countryController,
                              builder: (context, controller, focusNode) {
                                return TextField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  decoration: buildAddressInputDecoration(
                                    context,
                                    AppLocalizations.of(
                                      context,
                                    )!
                                        .enter_country_ucf,
                                  ),
                                );
                              },
                              suggestionsCallback: (name) async {
                                var countryResponse = await AddressRepository()
                                    .getCountryList(name: name);
                                return countryResponse.countries;
                              },
                              loadingBuilder: (context) => Center(
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!
                                      .loading_countries_ucf,
                                ),
                              ),
                              itemBuilder: (context, dynamic country) {
                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    country.name,
                                    style: TextStyle(color: MyTheme.font_grey),
                                  ),
                                );
                              },
                              onSelected: (value) {
                                onSelectCountryDuringAdd(value, setModalState);
                              },
                            ),
                          ),
                        ),
                      ],
                      Visibility(
                        visible: _showStateField,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "${AppLocalizations.of(context)!.state_ucf} *",
                                style: TextStyle(
                                  color: Color(0xff3E4447),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: SizedBox(
                                height: 40,
                                child: TypeAheadField(
                                  builder: (context, controller, focusNode) {
                                    return TextField(
                                      controller: controller,
                                      focusNode: focusNode,
                                      decoration: buildAddressInputDecoration(
                                        context,
                                        AppLocalizations.of(
                                          context,
                                        )!
                                            .enter_state_ucf,
                                      ),
                                    );
                                  },
                                  controller: _stateController,
                                  suggestionsCallback: (name) async {
                                    if (_selected_country == null) {
                                      return [];
                                    }
                                    var stateResponse =
                                        await AddressRepository()
                                            .getStateListByCountry(
                                      country_id: _selected_country!.id,
                                      name: name,
                                    );
                                    return stateResponse.states;
                                  },
                                  loadingBuilder: (context) => Center(
                                    child: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!
                                          .loading_states_ucf,
                                    ),
                                  ),
                                  itemBuilder: (context, dynamic state) {
                                    return ListTile(
                                      dense: true,
                                      title: Text(
                                        state.name,
                                        style: TextStyle(
                                          color: MyTheme.font_grey,
                                        ),
                                      ),
                                    );
                                  },
                                  onSelected: (value) {
                                    onSelectStateDuringAdd(
                                      value,
                                      setModalState,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          "${AppLocalizations.of(context)!.city_ucf} *",
                          style: TextStyle(
                            color: Color(0xff3E4447),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: SizedBox(
                          height: 40,
                          child: TypeAheadField(
                            controller: _cityController,
                            builder: (context, controller, focusNode) {
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                decoration: buildAddressInputDecoration(
                                  context,
                                  AppLocalizations.of(context)!.enter_city_ucf,
                                ),
                              );
                            },
                            suggestionsCallback: (name) async {
                              if (_showStateField) {
                                if (_selected_state == null) return [];
                                var cityResponse = await AddressRepository()
                                    .getCityListByState(
                                  state_id: _selected_state!.id,
                                  name: name,
                                );
                                return cityResponse.cities;
                              } else {
                                if (_selected_country == null) return [];
                                var cityResponse = await AddressRepository()
                                    .getCityListByCountry(
                                  country_id: _selected_country!.id!,
                                  name: name,
                                );
                                return cityResponse.cities;
                              }
                            },
                            loadingBuilder: (context) => Center(
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                )!
                                    .loading_cities_ucf,
                              ),
                            ),
                            itemBuilder: (context, dynamic city) {
                              return ListTile(
                                dense: true,
                                title: Text(
                                  city.name,
                                  style: TextStyle(color: MyTheme.font_grey),
                                ),
                              );
                            },
                            onSelected: (value) {
                              onSelectCityDuringAdd(value, setModalState);
                            },
                          ),
                        ),
                      ),
                      Visibility(
                        visible: _isAreaRequired,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "Area *",
                                style: TextStyle(
                                  color: Color(0xff3E4447),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: SizedBox(
                                height: 40,
                                child: TypeAheadField(
                                  controller: _areaController,
                                  builder: (context, controller, focusNode) {
                                    return TextField(
                                      controller: controller,
                                      focusNode: focusNode,
                                      decoration: buildAddressInputDecoration(
                                        context,
                                        "Enter Area",
                                      ),
                                    );
                                  },
                                  suggestionsCallback: (name) async {
                                    if (_selected_city == null) {
                                      return [];
                                    }
                                    var areaResponse = await AddressRepository()
                                        .getAriaListByCity(
                                      city_id: _selected_city!.id,
                                      name: name,
                                    );
                                    return areaResponse.cities;
                                  },
                                  loadingBuilder: (context) =>
                                      Center(child: Text("Loading Areas...")),
                                  itemBuilder: (context, dynamic area) {
                                    return ListTile(
                                      dense: true,
                                      title: Text(
                                        area.name,
                                        style: TextStyle(
                                          color: MyTheme.font_grey,
                                        ),
                                      ),
                                    );
                                  },
                                  onSelected: (value) {
                                    onSelectAreaDuringAdd(value, setModalState);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          AppLocalizations.of(context)!.postal_code,
                          style: TextStyle(
                            color: Color(0xff3E4447),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            controller: _postalCodeController,
                            decoration: buildAddressInputDecoration(
                              context,
                              AppLocalizations.of(
                                context,
                              )!
                                  .enter_postal_code_ucf,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          AppLocalizations.of(context)!.phone_ucf,
                          style: TextStyle(
                            color: Color(0xff3E4447),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            controller: _phoneController,
                            decoration: buildAddressInputDecoration(
                              context,
                              AppLocalizations.of(context)!.enter_phone_number,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Btn.minWidthFixHeight(
                        minWidth: 75,
                        height: 40,
                        color: Color.fromRGBO(253, 253, 253, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0),
                          side: BorderSide(color: MyTheme.light_grey, width: 1),
                        ),
                        child: Text(
                          LangText(context).local.close_ucf,
                          style: TextStyle(
                            color: MyTheme.accent_color,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 28.0),
                      child: Btn.minWidthFixHeight(
                        minWidth: 75,
                        height: 40,
                        color: MyTheme.accent_color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Text(
                          LangText(context).local.add_ucf,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () {
                          onAddressAdd(context);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  InputDecoration buildAddressInputDecoration(BuildContext context, hintText) {
    return InputDecoration(
      filled: true,
      fillColor: Color(0xffF6F7F8),
      hintText: hintText,
      hintStyle: TextStyle(fontSize: 12.0, color: Color(0xff999999)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: MyTheme.noColor, width: 0.5),
        borderRadius: const BorderRadius.all(Radius.circular(6.0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: MyTheme.noColor, width: 1.0),
        borderRadius: const BorderRadius.all(Radius.circular(6.0)),
      ),
      contentPadding: EdgeInsets.only(left: 8.0, top: 6.0, bottom: 6.0),
    );
  }

  Future buildShowUpdateFormDialog(
    BuildContext context,
    int index,
    bool showCountryField,
  ) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              insetPadding: EdgeInsets.symmetric(horizontal: 10),
              contentPadding: EdgeInsets.only(
                top: 36.0,
                left: 36.0,
                right: 36.0,
                bottom: 2.0,
              ),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          "${AppLocalizations.of(context)!.address_ucf} *",
                          style: TextStyle(
                            color: MyTheme.font_grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: SizedBox(
                          height: 55,
                          child: TextField(
                            controller: _addressControllerListForUpdate[index],
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            decoration: buildAddressInputDecoration(
                              context,
                              AppLocalizations.of(context)!.enter_address_ucf,
                            ),
                          ),
                        ),
                      ),
                      if (showCountryField) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            "${AppLocalizations.of(context)!.country_ucf} *",
                            style: TextStyle(
                              color: MyTheme.font_grey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: SizedBox(
                            height: 40,
                            child: TypeAheadField(
                              controller:
                                  _countryControllerListForUpdate[index],
                              builder: (context, controller, focusNode) {
                                return TextField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  decoration: buildAddressInputDecoration(
                                    context,
                                    AppLocalizations.of(
                                      context,
                                    )!
                                        .enter_country_ucf,
                                  ),
                                );
                              },
                              suggestionsCallback: (name) async {
                                var countryResponse = await AddressRepository()
                                    .getCountryList(name: name);
                                return countryResponse.countries;
                              },
                              loadingBuilder: (context) => Center(
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!
                                      .loading_countries_ucf,
                                ),
                              ),
                              itemBuilder: (context, dynamic country) {
                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    country.name,
                                    style: TextStyle(color: MyTheme.font_grey),
                                  ),
                                );
                              },
                              onSelected: (value) {
                                onSelectCountryDuringUpdate(
                                  index,
                                  value,
                                  setModalState,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                      Visibility(
                        visible: _showStateField,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "${AppLocalizations.of(context)!.state_ucf} *",
                                style: TextStyle(
                                  color: MyTheme.font_grey,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: SizedBox(
                                height: 40,
                                child: TypeAheadField(
                                  controller:
                                      _stateControllerListForUpdate[index],
                                  builder: (context, controller, focusNode) {
                                    return TextField(
                                      controller: controller,
                                      focusNode: focusNode,
                                      decoration: buildAddressInputDecoration(
                                        context,
                                        AppLocalizations.of(
                                          context,
                                        )!
                                            .enter_state_ucf,
                                      ),
                                    );
                                  },
                                  suggestionsCallback: (name) async {
                                    var stateResponse =
                                        await AddressRepository()
                                            .getStateListByCountry(
                                      country_id:
                                          _selected_country_list_for_update[
                                                  index]
                                              .id,
                                      name: name,
                                    );
                                    return stateResponse.states;
                                  },
                                  loadingBuilder: (context) => Center(
                                    child: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!
                                          .loading_states_ucf,
                                    ),
                                  ),
                                  itemBuilder: (context, dynamic state) {
                                    return ListTile(
                                      dense: true,
                                      title: Text(
                                        state.name,
                                        style: TextStyle(
                                          color: MyTheme.font_grey,
                                        ),
                                      ),
                                    );
                                  },
                                  onSelected: (value) {
                                    onSelectStateDuringUpdate(
                                      index,
                                      value,
                                      setModalState,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      //-- FIX ENDS HERE --
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          "${AppLocalizations.of(context)!.city_ucf} *",
                          style: TextStyle(
                            color: MyTheme.font_grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: SizedBox(
                          height: 40,
                          child: TypeAheadField(
                            controller: _cityControllerListForUpdate[index],
                            builder: (context, controller, focusNode) {
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                decoration: buildAddressInputDecoration(
                                  context,
                                  AppLocalizations.of(context)!.enter_city_ucf,
                                ),
                              );
                            },
                            suggestionsCallback: (name) async {
                              if (_selected_state_list_for_update[index] ==
                                  null) {
                                return [];
                              }
                              var cityResponse =
                                  await AddressRepository().getCityListByState(
                                state_id:
                                    _selected_state_list_for_update[index]!.id,
                                name: name,
                              );
                              return cityResponse.cities;
                            },
                            loadingBuilder: (context) => Center(
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                )!
                                    .loading_cities_ucf,
                              ),
                            ),
                            itemBuilder: (context, dynamic city) {
                              return ListTile(
                                dense: true,
                                title: Text(
                                  city.name,
                                  style: TextStyle(color: MyTheme.font_grey),
                                ),
                              );
                            },
                            onSelected: (value) {
                              onSelectCityDuringUpdate(
                                index,
                                value,
                                setModalState,
                              );
                            },
                          ),
                        ),
                      ),
                      Visibility(
                        visible: _isAreaRequired,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "Area *",
                                style: TextStyle(
                                  color: MyTheme.font_grey,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: SizedBox(
                                height: 40,
                                child: TypeAheadField(
                                  controller:
                                      _areaControllerListForUpdate[index],
                                  builder: (context, controller, focusNode) {
                                    return TextField(
                                      controller: controller,
                                      focusNode: focusNode,
                                      decoration: buildAddressInputDecoration(
                                        context,
                                        "Enter Area",
                                      ),
                                    );
                                  },
                                  suggestionsCallback: (name) async {
                                    if (_selected_city_list_for_update[index] ==
                                        null) {
                                      return [];
                                    }
                                    var areaResponse = await AddressRepository()
                                        .getAriaListByCity(
                                      city_id:
                                          _selected_city_list_for_update[index]!
                                              .id,
                                      name: name,
                                    );
                                    return areaResponse.cities;
                                  },
                                  loadingBuilder: (context) =>
                                      Center(child: Text("Loading Areas...")),
                                  itemBuilder: (context, dynamic area) {
                                    return ListTile(
                                      dense: true,
                                      title: Text(
                                        area.name,
                                        style: TextStyle(
                                          color: MyTheme.font_grey,
                                        ),
                                      ),
                                    );
                                  },
                                  onSelected: (value) {
                                    onSelectAreaDuringUpdate(
                                      index,
                                      value,
                                      setModalState,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          AppLocalizations.of(context)!.postal_code,
                          style: TextStyle(
                            color: MyTheme.font_grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            controller:
                                _postalCodeControllerListForUpdate[index],
                            decoration: buildAddressInputDecoration(
                              context,
                              AppLocalizations.of(
                                context,
                              )!
                                  .enter_postal_code_ucf,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          AppLocalizations.of(context)!.phone_ucf,
                          style: TextStyle(
                            color: MyTheme.font_grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            controller: _phoneControllerListForUpdate[index],
                            decoration: buildAddressInputDecoration(
                              context,
                              AppLocalizations.of(context)!.enter_phone_number,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Btn.minWidthFixHeight(
                        minWidth: 75,
                        height: 40,
                        color: Color.fromRGBO(253, 253, 253, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0),
                          side: BorderSide(
                            color: MyTheme.light_grey,
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.close_all_capital,
                          style: TextStyle(
                            color: MyTheme.accent_color,
                            fontSize: 13,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 28.0),
                      child: Btn.minWidthFixHeight(
                        minWidth: 75,
                        height: 40,
                        color: MyTheme.accent_color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.update_all_capital,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () {
                          onAddressUpdate(
                            context,
                            index,
                            _shippingAddressList[index].id,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: MyTheme.mainColor,
      scrolledUnderElevation: 0.0,
      centerTitle: false,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(CupertinoIcons.arrow_left, color: MyTheme.dark_font_grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.addresses_of_user,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xff3E4447),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "* ${AppLocalizations.of(context)!.double_tap_on_an_address_to_make_it_default}",
            style: TextStyle(fontSize: 12, color: Color(0xff6B7377)),
          ),
        ],
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  buildAddressList() {
    if (is_logged_in.$ == false) {
      return SizedBox(
        height: 100,
        child: Center(
          child: Text(
            AppLocalizations.of(context)!.you_need_to_log_in,
            style: TextStyle(color: MyTheme.font_grey),
          ),
        ),
      );
    } else if (_isInitial && _shippingAddressList.isEmpty) {
      return SingleChildScrollView(
        child: ShimmerHelper().buildListShimmer(
          item_count: 5,
          item_height: 100.0,
        ),
      );
    } else if (_shippingAddressList.isNotEmpty) {
      return ListView.separated(
        separatorBuilder: (context, index) => SizedBox(height: 16),
        itemCount: _shippingAddressList.length,
        scrollDirection: Axis.vertical,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return buildAddressItemCard(index);
        },
      );
    } else {
      return SizedBox(
        height: 100,
        child: Center(
          child: Text(
            AppLocalizations.of(context)!.no_address_is_added,
            style: TextStyle(color: MyTheme.font_grey),
          ),
        ),
      );
    }
  }

  GestureDetector buildAddressItemCard(int index) {
    return GestureDetector(
      onDoubleTap: () {
        if (_default_shipping_address != _shippingAddressList[index].id) {
          onAddressSwitch(_shippingAddressList[index].id);
        }
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 400),
        decoration: BoxDecorations.buildBoxDecoration_1().copyWith(
          border: Border.all(
            color: _default_shipping_address == _shippingAddressList[index].id
                ? MyTheme.accent_color
                : MyTheme.light_grey,
            width: _default_shipping_address == _shippingAddressList[index].id
                ? 1.0
                : 0.0,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildAddressInfoRow(
                    AppLocalizations.of(context)!.address_ucf,
                    _shippingAddressList[index].address ?? "",
                  ),
                  if (_shippingAddressList[index].area_name != null &&
                      _shippingAddressList[index].area_name.isNotEmpty)
                    buildAddressInfoRow(
                      "Area",
                      _shippingAddressList[index].area_name ?? "",
                    ),
                  buildAddressInfoRow(
                    AppLocalizations.of(context)!.city_ucf,
                    _shippingAddressList[index].city_name ?? "",
                  ),
                  if (_shippingAddressList[index].state_name != null &&
                      _shippingAddressList[index].state_name.isNotEmpty)
                    buildAddressInfoRow(
                      AppLocalizations.of(context)!.state_ucf,
                      _shippingAddressList[index].state_name ?? "",
                    ),
                  buildAddressInfoRow(
                    AppLocalizations.of(context)!.country_ucf,
                    _shippingAddressList[index].country_name ?? "",
                  ),
                  buildAddressInfoRow(
                    AppLocalizations.of(context)!.postal_code,
                    _shippingAddressList[index].postal_code ?? "",
                  ),
                  buildAddressInfoRow(
                    AppLocalizations.of(context)!.phone_ucf,
                    _shippingAddressList[index].phone ?? "",
                    isLast: true,
                  ),
                ],
              ),
            ),
            Positioned(
              right: app_language_rtl.$! ? null : 0.0,
              left: app_language_rtl.$! ? 0.0 : null,
              top: 10.0,
              child: showOptions(listIndex: index),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAddressInfoRow(
    String label,
    String value, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 75,
            child: Text(
              label,
              style: TextStyle(color: const Color(0xff6B7377)),
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Text(
              value,
              maxLines: 2,
              style: TextStyle(
                color: MyTheme.dark_grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  BottomAppBar buildBottomAppBar(BuildContext context) {
    return BottomAppBar(
      color: Colors.transparent,
      elevation: 0.0,
      child: Visibility(
        visible: widget.from_shipping_info,
        child: SizedBox(
          height: 50,
          child: Btn.minWidthFixHeight(
            minWidth: MediaQuery.of(context).size.width,
            height: 50,
            color: MyTheme.accent_color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.0),
            ),
            child: Text(
              AppLocalizations.of(context)!.back_to_shipping_info,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }

  Widget showOptions({required int listIndex}) {
    return SizedBox(
      width: 45,
      child: PopupMenuButton<MenuOptions>(
        offset: Offset(-25, 0),
        child: Padding(
          padding: EdgeInsets.zero,
          child: Container(
            width: 45,
            padding: EdgeInsets.symmetric(horizontal: 15),
            alignment: Alignment.topRight,
            child: Image.asset(
              "assets/more.png",
              width: 4,
              height: 16,
              fit: BoxFit.contain,
              color: MyTheme.grey_153,
            ),
          ),
        ),
        onSelected: (MenuOptions result) {
          _tabOption(result.index, listIndex);
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuOptions>>[
          PopupMenuItem<MenuOptions>(
            value: MenuOptions.Edit,
            child: Text(AppLocalizations.of(context)!.edit_ucf),
          ),
          PopupMenuItem<MenuOptions>(
            value: MenuOptions.Delete,
            child: Text(AppLocalizations.of(context)!.delete_ucf),
          ),
          PopupMenuItem<MenuOptions>(
            value: MenuOptions.AddLocation,
            child: Text(AppLocalizations.of(context)!.add_location_ucf),
          ),
        ],
      ),
    );
  }
}

enum MenuOptions { Edit, Delete, AddLocation }
