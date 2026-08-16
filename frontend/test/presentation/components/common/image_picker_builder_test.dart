import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/presentation/components/common/image_picker_builder.dart';
import 'package:octo_image/octo_image.dart';
import '../../../test_helper.dart';

void main() {
  // Corrected mock data with valid 6-char blurhash strings (required by flutter_blurhash)
  final mockInitialImages = [
    {'url': 'http://image1.jpg', 'blurhash': r"|HF}[*IU1j-p$gNHVsofWXEMofxCNGt6s.WYazayEgjZ$%WVNGofa}f6kCIrof$$ayNHayoyayof-oR*Rjs:Nbj]xZWVaeNdofn~WBoLWBofoLWVxtayNHa}xZj[Rkj[WV%1fkIpoet6WBs.j[R*xaayRka#ofoLR*fkjs", 'id': '1'},
    {'url': 'http://image2.jpg', 'blurhash': r"|HF}[*IU1j-p$gNHVsofWXEMofxCNGt6s.WYazayEgjZ$%WVNGofa}f6kCIrof$$ayNHayoyayof-oR*Rjs:Nbj]xZWVaeNdofn~WBoLWBofoLWVxtayNHa}xZj[Rkj[WV%1fkIpoet6WBs.j[R*xaayRka#ofoLR*fkjs", 'id': '2'},
  ];

  // Wrapper using SingleChildScrollView and a large SizedBox to prevent RenderFlex Overflow (Fix #1)
  Widget buildPickerTestWidget(Widget child) {
    return buildTestWidget(
      SingleChildScrollView( 
        child: SizedBox(
          width: 400, // Fixed width for predictable layout
          height: 1000, // Ample vertical height
          child: child,
        ),
      ),
    );
  }

  testWidgets('renders 6 image slots (1 large, 5 small)', (tester) async {
    await tester.pumpWidget(buildPickerTestWidget(
      ImagePickerBuilder(maxImages: 6, onImagesChanged: (_, __) {}),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(DottedBorder), findsNWidgets(6));
  });

  testWidgets('loads initial images correctly', (tester) async {
    await tester.pumpWidget(buildPickerTestWidget(
      ImagePickerBuilder(
        maxImages: 6,
        onImagesChanged: (_, __) {},
        initialImages: mockInitialImages,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.add_rounded), findsNWidgets(4));
    expect(find.byType(OctoImage), findsNWidgets(2));
  });

  testWidgets('remove button is visible on non-signup profile page if > 2 images', (tester) async {
    final threeImages = [...mockInitialImages, {'url': 'http://image3.jpg', 'blurhash': r"|HF}[*IU1j-p$gNHVsofWXEMofxCNGt6s.WYazayEgjZ$%WVNGofa}f6kCIrof$$ayNHayoyayof-oR*Rjs:Nbj]xZWVaeNdofn~WBoLWBofoLWVxtayNHa}xZj[Rkj[WV%1fkIpoet6WBs.j[R*xaayRka#ofoLR*fkjs", 'id': '3'}]; 
    await tester.pumpWidget(buildPickerTestWidget(
      ImagePickerBuilder(
        maxImages: 6,
        onImagesChanged: (_, __) {},
        initialImages: threeImages,
        onSignUp: false,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.close), findsNWidgets(3));
  });
}