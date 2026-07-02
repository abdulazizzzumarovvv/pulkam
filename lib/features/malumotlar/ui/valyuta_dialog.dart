import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulkam/features/malumotlar/logic/sozlamalar_cubit.dart';
import 'package:pulkam/l10n.dart';

class _Valyuta {
  final String nom;
  final String kod;
  final String belgi;
  const _Valyuta(this.nom, this.kod, this.belgi);
}

const _kMashhur = [
  _Valyuta("O'zbek soʼmi", 'UZS', "soʼm"),
  _Valyuta('AQSH dollari', 'USD', '\$'),
  _Valyuta('Yevropa evro', 'EUR', '€'),
  _Valyuta('Rossiya rubli', 'RUB', '₽'),
  _Valyuta('Britaniya funt sterlingi', 'GBP', '£'),
];

const _kBarchasi = [
  _Valyuta('Avstraliya dollari', 'AUD', 'A\$'),
  _Valyuta('Kanada dollari', 'CAD', 'CA\$'),
  _Valyuta('Xitoy yuani', 'CNY', 'CN¥'),
  _Valyuta('Yaponiya iyenasi', 'JPY', 'JP¥'),
  _Valyuta('Shveytsariya franki', 'CHF', 'CHF'),
  _Valyuta('Hindiston rupiyasi', 'INR', '₹'),
  _Valyuta('Braziliya reali', 'BRL', 'R\$'),
  _Valyuta('Janubiy Koreya voni', 'KRW', '₩'),
  _Valyuta('Meksika pesosi', 'MXN', 'MX\$'),
  _Valyuta('Singapur dollari', 'SGD', 'S\$'),
  _Valyuta('Norvegiya kronasi', 'NOK', 'kr'),
  _Valyuta('Shvetsiya kronasi', 'SEK', 'kr'),
  _Valyuta('Daniya kronasi', 'DKK', 'kr'),
  _Valyuta('Polsha zlotiyi', 'PLN', 'zł'),
  _Valyuta('Chexiya kronasi', 'CZK', 'Kč'),
  _Valyuta('Vengriya forinti', 'HUF', 'Ft'),
  _Valyuta('Ruminiya leyi', 'RON', 'lei'),
  _Valyuta('Turk lirasi', 'TRY', '₺'),
  _Valyuta('Isroil sheqeli', 'ILS', '₪'),
  _Valyuta('Saudiya Arabistoni riyoli', 'SAR', '﷼'),
  _Valyuta('BAA dirhami', 'AED', 'د.إ'),
  _Valyuta('Misr funti', 'EGP', 'E£'),
  _Valyuta('Janubiy Afrika rendi', 'ZAR', 'R'),
  _Valyuta('Nigeriya nayrasi', 'NGN', '₦'),
  _Valyuta('Keniya shillingi', 'KES', 'KSh'),
  _Valyuta('Gana sedisi', 'GHS', 'GH₵'),
  _Valyuta('Qozogʻiston tengesi', 'KZT', '₸'),
  _Valyuta('Ukraina grivnasi', 'UAH', '₴'),
  _Valyuta('Belarusiya rubli', 'BYN', 'Br'),
  _Valyuta('Ozarbayjon manati', 'AZN', '₼'),
  _Valyuta('Gruziya larisi', 'GEL', '₾'),
  _Valyuta('Armaniston drami', 'AMD', '֏'),
  _Valyuta('Qirgʻiziston somi', 'KGS', 'с'),
  _Valyuta('Tojikiston somoniysi', 'TJS', 'SM'),
  _Valyuta('Turkmaniston manati', 'TMT', 'T'),
  _Valyuta('Malayziya ringgiti', 'MYR', 'RM'),
  _Valyuta('Indoneziya rupiyasi', 'IDR', 'Rp'),
  _Valyuta('Tailand bati', 'THB', '฿'),
  _Valyuta('Vyetnam dongi', 'VND', '₫'),
  _Valyuta('Filippin pesosi', 'PHP', '₱'),
  _Valyuta('Pokiston rupiyasi', 'PKR', '₨'),
  _Valyuta('Bangladesh takasi', 'BDT', '৳'),
  _Valyuta('Argentina pesosi', 'ARS', 'AR\$'),
  _Valyuta('Chili pesosi', 'CLP', 'CL\$'),
  _Valyuta('Kolumbiya pesosi', 'COP', 'CO\$'),
  _Valyuta('Peru soli', 'PEN', 'S/.'),
  _Valyuta('Yangi Zelandiya dollari', 'NZD', 'NZ\$'),
];

Future<void> showValyutaDialog(BuildContext context) {
  final soz = context.read<SozlamalarCubit>();
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Yopish',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (ctx, anim, _) => _ValyutaDialog(
      cubit: soz,
      bg: soz.state.mavzuRang,
      selected: soz.state.valyutaKod,
    ),
    transitionBuilder: (ctx, anim, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
      child: child,
    ),
  );
}

class _ValyutaDialog extends StatefulWidget {
  final SozlamalarCubit cubit;
  final Color bg;
  final String selected;
  const _ValyutaDialog({
    required this.cubit,
    required this.bg,
    required this.selected,
  });

  @override
  State<_ValyutaDialog> createState() => _ValyutaDialogState();
}

class _ValyutaDialogState extends State<_ValyutaDialog> {
  late String _selected;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_Valyuta> _filter(List<_Valyuta> list) {
    if (_query.isEmpty) return list;
    return list
        .where((v) =>
            v.nom.toLowerCase().contains(_query) ||
            v.kod.toLowerCase().contains(_query))
        .toList();
  }

  Widget _tile(_Valyuta v) {
    final isSelected = v.kod == _selected;
    return InkWell(
      onTap: () => setState(() => _selected = v.kod),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.3),
                  width: isSelected ? 5.5 : 1.5,
                ),
                color: isSelected ? Colors.white : Colors.transparent,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                v.nom,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: isSelected ? 1.0 : 0.85),
                  fontSize: 15,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            Text(
              v.kod,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.45),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bg = widget.bg;
    final cardBg = Color.alphaBlend(Colors.white.withValues(alpha: 0.07), bg);
    final filteredMashhur = _filter(_kMashhur);
    final filteredBarchasi = _filter(_kBarchasi);

    return Stack(
      children: [
        // Blur background
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(color: Colors.black.withValues(alpha: 0.35)),
            ),
          ),
        ),

        // Dialog
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: MediaQuery.of(context).size.height * 0.08,
            ),
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 40,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                      child: Text(
                        context.l10n.valyutaniTanlang,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    // Qidiruv
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _searchCtrl,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: l10n.nomYokiKod,
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.35),
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: Colors.white.withValues(alpha: 0.4),
                              size: 20,
                            ),
                            suffixIcon: _query.isNotEmpty
                                ? GestureDetector(
                                    onTap: () => _searchCtrl.clear(),
                                    child: Icon(
                                      Icons.close_rounded,
                                      color:
                                          Colors.white.withValues(alpha: 0.4),
                                      size: 18,
                                    ),
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 12),
                            isDense: true,
                          ),
                        ),
                      ),
                    ),

                    Divider(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.08)),

                    // Ro'yxat
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.only(bottom: 16),
                        children: [
                          if (filteredMashhur.isNotEmpty) ...[
                            _sectionLabel(l10n.mashhurValyutalar),
                            ...filteredMashhur.map(_tile),
                            Divider(
                                height: 1,
                                color:
                                    Colors.white.withValues(alpha: 0.06)),
                          ],
                          if (filteredBarchasi.isNotEmpty) ...[
                            _sectionLabel(l10n.barchaValyutalar),
                            ...filteredBarchasi.map(_tile),
                          ],
                          if (filteredMashhur.isEmpty &&
                              filteredBarchasi.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(32),
                              child: Center(
                                child: Text(
                                  l10n.hechNarsa,
                                  style: TextStyle(
                                    color:
                                        Colors.white.withValues(alpha: 0.35),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Saqlash
                    Divider(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.08)),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _GlassCircleBtn(
                            icon: Icons.close_rounded,
                            onTap: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 20),
                          _GlassCircleBtn(
                            icon: Icons.check_rounded,
                            onTap: () {
                              widget.cubit.setValyuta(_selected);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GlassCircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassCircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1.2,
              ),
            ),
            child: Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 24),
          ),
        ),
      ),
    );
  }
}
