import 'package:flutter_test/flutter_test.dart';
import 'package:rent_app/features/profile/domain/portfolio_item_model.dart';
import 'package:rent_app/features/profile/domain/professional_profile_model.dart';

void main() {
  group('PortfolioItemModel Tests', () {
    test('encodeDescription and metadata getters parse fields correctly', () {
      final jsonDesc = PortfolioItemModel.encodeDescription(
        summary: 'Commercial shoot for Nike',
        workType: 'Commercial',
        userRole: 'Director of Photography',
        year: '2025',
        gallery: ['https://img1.jpg', 'https://img2.jpg'],
      );

      final item = PortfolioItemModel(
        id: 'p1',
        professionalProfileId: 'pro1',
        title: 'Nike Campaign',
        description: jsonDesc,
        mediaUrl: 'https://cover.jpg',
        mediaType: 'video',
        externalUrl: 'https://vimeo.com/12345',
        displayOrder: 1,
      );

      expect(item.workType, equals('Commercial'));
      expect(item.userRole, equals('Director of Photography'));
      expect(item.year, equals('2025'));
      expect(item.shortDescription, equals('Commercial shoot for Nike'));
      expect(item.galleryImages, equals(['https://img1.jpg', 'https://img2.jpg']));
      expect(item.isVideo, isTrue);
    });

    test('PortfolioItemModel falls back gracefully when description is plain text', () {
      const item = PortfolioItemModel(
        id: 'p2',
        professionalProfileId: 'pro1',
        title: 'Short Film',
        description: 'Plain text description of a movie',
        mediaType: 'image',
      );

      expect(item.workType, equals('Project'));
      expect(item.userRole, isNull);
      expect(item.year, isNull);
      expect(item.shortDescription, equals('Plain text description of a movie'));
      expect(item.galleryImages, isEmpty);
      expect(item.isImage, isTrue);
    });

    test('PortfolioItemModel copyWith works correctly', () {
      const item = PortfolioItemModel(
        id: 'p1',
        professionalProfileId: 'pro1',
        title: 'Original Title',
        displayOrder: 0,
      );

      final updated = item.copyWith(
        title: 'New Title',
        displayOrder: 5,
      );

      expect(updated.id, equals('p1'));
      expect(updated.title, equals('New Title'));
      expect(updated.displayOrder, equals(5));
    });
  });

  group('Social Links & Extended Platforms Tests', () {
    test('encodeWebsiteData encodes and decodes extended social links correctly', () {
      final encoded = ProfessionalProfileModel.encodeWebsiteData(
        website: 'https://alexdop.com',
        imdb: 'https://imdb.com/name/nm999',
        artstation: 'https://artstation.com/alexdop',
        dribbble: 'https://dribbble.com/alexdop',
        tiktok: 'https://tiktok.com/@alexdop',
        soundcloud: 'https://soundcloud.com/alexdop',
        spotify: 'https://spotify.com/artist/999',
        otherPortfolio: 'https://vfxlink.com',
        customLinks: [
          const CustomSocialLink(id: 'c1', title: 'IMDb Pro', url: 'https://pro.imdb.com/nm999'),
          const CustomSocialLink(id: 'c2', title: 'VFX Showreel Link', url: 'https://showreel.com'),
        ],
      );

      final pro = ProfessionalProfileModel(
        id: 'pro1',
        profileId: 'user1',
        professionalTitle: 'Director of Photography',
        linkedinUrl: 'https://linkedin.com/in/alexdop',
        instagramUrl: 'https://instagram.com/alexdop',
        behanceUrl: 'https://behance.net/alexdop',
        vimeoUrl: 'https://vimeo.com/alexdop',
        youtubeUrl: 'https://youtube.com/@alexdop',
        websiteUrl: encoded,
      );

      expect(pro.actualWebsiteUrl, equals('https://alexdop.com'));
      expect(pro.imdbUrl, equals('https://imdb.com/name/nm999'));
      expect(pro.artstationUrl, equals('https://artstation.com/alexdop'));
      expect(pro.dribbbleUrl, equals('https://dribbble.com/alexdop'));
      expect(pro.tiktokUrl, equals('https://tiktok.com/@alexdop'));
      expect(pro.soundcloudUrl, equals('https://soundcloud.com/alexdop'));
      expect(pro.spotifyUrl, equals('https://spotify.com/artist/999'));
      expect(pro.otherPortfolioUrl, equals('https://vfxlink.com'));

      expect(pro.customSocialLinks.length, equals(2));
      expect(pro.customSocialLinks[0].title, equals('IMDb Pro'));
      expect(pro.customSocialLinks[0].url, equals('https://pro.imdb.com/nm999'));

      // Verify allSocialLinks contains 13 standard platforms + 2 custom links = 15 total links!
      expect(pro.allSocialLinks.length, equals(15));
    });

    test('allSocialLinks only includes active non-empty platforms', () {
      const pro = ProfessionalProfileModel(
        id: 'pro2',
        profileId: 'user2',
        professionalTitle: 'Camera Operator',
        linkedinUrl: 'https://linkedin.com/in/cameraop',
        websiteUrl: 'https://cameraop.com',
      );

      expect(pro.allSocialLinks.length, equals(2));
      expect(pro.allSocialLinks[0].label, equals('LinkedIn'));
      expect(pro.allSocialLinks[1].label, equals('Personal Website'));
    });

    test('encodeWebsiteData outputs plain URL when only personal website is provided', () {
      final encoded = ProfessionalProfileModel.encodeWebsiteData(
        website: 'https://cameraop.com',
      );

      expect(encoded, equals('https://cameraop.com'));

      const pro = ProfessionalProfileModel(
        id: 'pro3',
        profileId: 'user3',
        professionalTitle: 'Colorist',
        websiteUrl: 'https://cameraop.com',
      );

      expect(pro.actualWebsiteUrl, equals('https://cameraop.com'));
      expect(pro.imdbUrl, isNull);
      expect(pro.customSocialLinks, isEmpty);
      expect(pro.allSocialLinks.length, equals(1));
    });
  });
}
